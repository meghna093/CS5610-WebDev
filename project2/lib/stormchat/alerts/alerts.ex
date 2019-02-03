defmodule Stormchat.Alerts do
  @moduledoc """
  The Alerts context.
  """

  # requirements for xml parsing via Dave Kuhlman
  # http://davekuhlman.org/static/search_xml05.ex
  require Record
  Record.defrecord :xmlElement,
    Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,
    Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlAttribute,
    Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")

  import Ecto.Query, warn: false
  alias Stormchat.Repo

  alias Stormchat.Alerts.Alert
  alias Stormchat.Alerts.County
  alias Stormchat.Locations
  alias Stormchat.Locations.Location
  alias Stormchat.Locations.LocationCounty
  alias Stormchat.Users

  # gets new NWS alerts and sends SMS messages to affected users
  def update do
    get_atom_feed()
    |> filter_old()
    |> Enum.each(fn(em) -> complete_and_notify(em) end)
  end

  # gets a list of maps, each representing an alert from the NWS ATOM feed
  def get_atom_feed() do
    {msg, resp} = HTTPoison.get("https://alerts.weather.gov/cap/us.php?x=0")

    case msg do
      :error ->
        IO.puts("http error getting atom feed")
        IO.inspect(resp)
        get_atom_feed()
      :ok ->
        xml_doc = http_to_xml(resp)

        if xml_doc == nil do
          []
        else
          # strategy for catching xmerl_xpath exits via OvermindDL1
          # https://elixirforum.com/t/rescuing-from-an-erlang-error/1132/2
          try do
            :xmerl_xpath.string('//entry', http_to_xml(resp))
            |> Enum.map(fn (xe) -> xml_to_map(xe) end)
          catch
            :exit, _exit -> []
          end
        end
    end
  end

  # converts an xml entry element to a map
  def xml_to_map(xml_entry) do
    xmlElement(xml_entry, :content)
    |> Enum.filter(fn(rr) -> Record.is_record(rr, :xmlElement) end)
    |> Enum.filter(fn(rr) -> Record.is_record(List.first(xmlElement(rr, :content)), :xmlText) end)
    |> Enum.reduce(%{}, fn (xe, acc) -> Map.put(acc, get_element_name(xe), to_string(xmlText(List.first(xmlElement(xe, :content)), :value))) end)
  end

  # gets the element name as an atom, makes necessary edits to match db schema
  def get_element_name(element) do
    name =
      xmlElement(element, :name)
      |> Atom.to_string()
      |> String.replace("\"", "")
      |> String.replace("cap:", "")
      |> String.to_atom()

    if name == :id do
      :identifier
    else
      name
    end
  end

  # removes alerts from the given list that already exist in the alerts repo
  def filter_old(entry_maps) do
    entry_maps
    |> Enum.filter(fn(em) -> get_alert_by_identifier(em[:identifier]) == nil end)
  end

  # converts an http response to xml
  def http_to_xml(resp) do
    # strategy for catching xmerl_scan exits via OvermindDL1
    # https://elixirforum.com/t/rescuing-from-an-erlang-error/1132/2
    try do
      {xml_doc, _rest} =
        resp.body
        |> to_charlist()
        |> :xmerl_scan.string()

      xml_doc
    catch
      :exit, _exit -> nil
    end
  end

  def get_instruction_string(instruction_element) do
    case xmlElement(instruction_element, :content) do
      [] -> "none"
      [first | _rest] -> to_string(xmlText(first, :value))
    end
  end

  # gets the rest of the info necessary to create an alert from the CAP feed
  # gets the county codes from the CAP feed
  # creates new alert and county records
  # notifies affected users
  def complete_and_notify(new_entry_map) do
    # get the cap response
    {msg, resp} = HTTPoison.get(new_entry_map[:identifier])

    case msg do
      :error ->
        IO.puts("http error getting cap feed")
        IO.inspect(resp)
        complete_and_notify(new_entry_map)
      :ok ->
        # convert the cap response to xml
        xml_doc = http_to_xml(resp)

        # get the description string, set to "none" if there is no description
        dscrpt =
          case :xmerl_xpath.string('//description', xml_doc) do
            [description | _rest] -> to_string(xmlText(List.first(xmlElement(description, :content)), :value))
            _error -> "none"
          end

        xpath_result = :xmerl_xpath.string('//instruction', xml_doc)

        # get the instruction string, set to "none" if there is no instruction
        nstrct =
          case xpath_result do
            [instruction | _rest] -> get_instruction_string(instruction)
            _error -> "none"
          end

        # insert the description and instruction into the new entry map
        new_entry_map
        |> Map.put(:description, dscrpt)
        |> Map.put(:instruction, nstrct)
        |> create_alert()

        # get the newly created alert
        alert = get_alert_by_identifier(new_entry_map[:identifier])

        # get all fips codes, insert new country record per code, notify affected users
        affected_fips =
          :xmerl_xpath.string('//geocode', xml_doc)
          |> Enum.filter(fn(gc) -> is_and_has_fips(gc) end)
          |> Enum.map(fn(gc) -> get_code(gc) end)

        # for each fips code, insert new country record
        Enum.each(affected_fips, fn(ff) -> create_county(%{alert_id: alert.id, fips_code: ff}) end)

        # get unique users affected and notify each
        list_of_user_lists =
          affected_fips
            |> Enum.map(fn(ff) ->
              query = from l in Location,
                join: c in LocationCounty, on: l.id == c.location_id,
                where: c.fips_code == ^ff,
                select: l.user_id

              case Repo.all(query) do
                nil -> []
                user_list -> user_list
              end end)

        # flatten list and remove duplicates
        affected_users =
          List.flatten(list_of_user_lists)
          |> Enum.uniq()


        # filter by user notification preferences
        affected_users
        |> Enum.filter(fn(uu) -> matches_preferences(alert, uu) end)
        |> Enum.each(fn(uu) -> notify(uu, alert) end)
    end
  end

  # returns true if the user's preferences are set
  # such that they want to be notified of the given alert
  # returns false if the user's are set
  # such that they don't want to be notified of the given alert
  # preferences filter by urgency, severity, and certainty
  def matches_preferences(alert, user_id) do
    user = Users.get_user(user_id)

    urgency = true
    severity = true
    certainty = true

    immediate = ["Immediate"]
    expected = ["Immediate", "Expected"]
    future = ["Immediate", "Expected", "Future"]
    past = ["Immediate", "Expected", "Future", "Past"]

    extreme = ["Extreme"]
    severe = ["Extreme", "Severe"]
    moderate = ["Extreme", "Severe", "Moderate"]
    minor = ["Extreme", "Severe", "Moderate", "Minor"]

    observed = ["Observed"]
    likely = ["Observed", "Likely"]
    possible = ["Observed", "Likely", "Possible"]
    unlikely = ["Observed", "Likely", "Possible", "Unlikely"]

    if user != nil do
      urgency =
        case user.urgency do
          "Immediate" -> Enum.member?(immediate, alert.urgency)
          "Expected" -> Enum.member?(expected, alert.urgency)
          "Future" -> Enum.member?(future, alert.urgency)
          _else -> Enum.member?(past, alert.urgency)
        end

      severity =
        case user.severity do
          "Extreme" -> Enum.member?(extreme, alert.severity)
          "Severe" -> Enum.member?(severe, alert.severity)
          "Moderate" -> Enum.member?(moderate, alert.severity)
          _else -> Enum.member?(minor, alert.severity)
        end

      certainty =
        case user.certainty do
          "Observed" -> Enum.member?(observed, alert.certainty)
          "Likely" -> Enum.member?(likely, alert.certainty)
          "Possible" -> Enum.member?(possible, alert.certainty)
          _else -> Enum.member?(unlikely, alert.certainty)
        end

      urgency && severity && certainty
    else
      false
    end
  end

  def get_code(geocode) do
    [_valueName | [value | _rest]] =
      xmlElement(geocode, :content)
      |> Enum.filter(fn(rr) -> Record.is_record(rr, :xmlElement) end)

    # IO.inspect(value)

    to_string(xmlText(List.first(xmlElement(value, :content)), :value))
  end

  # returns whether the geocode is and has a fips code
  def is_and_has_fips(geocode) do
    [valueName | [value | _rest]] =
      xmlElement(geocode, :content)
      |> Enum.filter(fn(rr) -> Record.is_record(rr, :xmlElement) end)

    valueName_content = xmlElement(valueName, :content)
    value_content = xmlElement(value, :content)

    # guard against non-fips valueNames and empty fips values
    valueName_content != []
      && value_content != []
      && xmlText(List.first(valueName_content), :value) == 'FIPS6'
  end

  # creates and returns the notification message body for the given alert
  # 1600 total character limit broken into 160 character chucks
  # with each chunk being its own message
  def message_text(alert) do
    alert.title <> " https://stormchat.cdriskill.com/alert/#{alert.id}"
  end

  def send_sms(to, text) do
    account = Application.get_env(:stormchat, :twilio_account)
    key = Application.get_env(:stormchat, :twilio_key)
    authentication = "Basic " <> Base.encode64(account <> ":" <> key)

    url = "https://api.twilio.com/2010-04-01/Accounts/" <> account <> "/Messages.json"

    body = URI.encode_query([
      {"To", "+1" <> to},
      {"From", "+16178706887"},
      {"Body", text}])

    headers = [{"Authorization", authentication}, {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}]

    {m, resp} = HTTPoison.post(url, body, headers)

    case m do
      :error ->
        IO.puts("error posting to Twilio API")
        IO.inspect(resp)
      :ok ->
        IO.puts("successful post to Twilio API")
    end
  end

  # notify the given user of the given alert
  def notify(user_id, alert) do
    user = Users.get_user(user_id)
    to = user.phone
    text = message_text(alert)
    send_sms(to, text)
  end

  @doc """
  Returns the list of alerts.

  ## Examples

      iex> list_alerts()
      [%Alert{}, ...]

  """
  def list_alerts do
    Repo.all(Alert)
  end

  # returns the max number of alerts per "page load"
  def alert_limit do
    10
  end

  # gets the given user's active alerts for the given location
  def get_active_by_location(user_id, location_id) do
    now = DateTime.utc_now()
    al = alert_limit()

    if location_id == "undefined" do
      []
    else
      query =
        from a in Alert,
          join: c in County, on: c.alert_id == a.id,
          join: lc in LocationCounty, on: lc.fips_code == c.fips_code,
          join: l in Location, on: l.id == lc.location_id,
          where: l.user_id == ^user_id and l.id == ^location_id and a.expires > ^now,
          distinct: a.id,
          order_by: [desc: a.inserted_at],
          limit: ^al,
          select: a

      Repo.all(query)
    end
  end

  # gets the next chunk of older active alerts for the given user and location
  def get_older_active_by_location(user_id, location_id, oldest_id) do
    if location_id == "undefined" || oldest_id == "undefined" do
      []
    else
      now = DateTime.utc_now()
      al = alert_limit()
      oldest_alert = get_alert(oldest_id)
      inserted_at = oldest_alert.inserted_at

      query =
        from a in Alert,
          join: c in County, on: c.alert_id == a.id,
          join: lc in LocationCounty, on: lc.fips_code == c.fips_code,
          join: l in Location, on: l.id == lc.location_id,
          where: l.user_id == ^user_id and l.id == ^location_id and a.expires > ^now and a.inserted_at < ^inserted_at,
          distinct: a.id,
          order_by: [desc: a.inserted_at],
          limit: ^al,
          select: a

      Repo.all(query)
    end
  end

  # gets the given user's historical alerts for the given location
  def get_historical_by_location(user_id, location_id) do
    now = DateTime.utc_now()
    al = alert_limit()

    if location_id == "undefined" do
      []
    else
      query =
        from a in Alert,
          join: c in County, on: c.alert_id == a.id,
          join: lc in LocationCounty, on: lc.fips_code == c.fips_code,
          join: l in Location, on: l.id == lc.location_id,
          where: l.user_id == ^user_id and l.id == ^location_id and a.expires <= ^now,
          distinct: a.id,
          order_by: [desc: a.inserted_at],
          limit: ^al,
          select: a

      Repo.all(query)
    end
  end

  # gets the next chunk of older historical alerts for the given user and location
  def get_older_historical_by_location(user_id, location_id, oldest_id) do
    if location_id == "undefined" || oldest_id == "undefined" do
      []
    else
      now = DateTime.utc_now()
      al = alert_limit()
      oldest_alert = get_alert(oldest_id)
      inserted_at = oldest_alert.inserted_at

      query =
        from a in Alert,
          join: c in County, on: c.alert_id == a.id,
          join: lc in LocationCounty, on: lc.fips_code == c.fips_code,
          join: l in Location, on: l.id == lc.location_id,
          where: l.user_id == ^user_id and l.id == ^location_id and a.expires <= ^now and a.inserted_at < ^inserted_at,
          distinct: a.id,
          order_by: [desc: a.inserted_at],
          limit: ^al,
          select: a

      Repo.all(query)
    end
  end

  # gets the active alerts for the given lat and long
  def get_active_by_latlong(lat, long) do
    if lat == "undefined" || long == "undefined" do
      []
    else
      fips_codes = Locations.get_fips_by_latlong(lat, long)
      now = DateTime.utc_now()
      al = alert_limit()

      query =
        from a in Alert,
          join: c in County, on: c.alert_id == a.id,
          where: c.fips_code in ^fips_codes and a.expires > ^now,
          distinct: a.id,
          order_by: [desc: a.inserted_at],
          limit: ^al,
          select: a

      Repo.all(query)
    end
  end

  # gets the next chunk of older active alerts for the given lat and long
  def get_older_active_by_latlong(lat, long, oldest_id) do
    if lat == "undefined" || long == "undefined" || oldest_id == "undefined" do
      []
    else
      fips_codes = Locations.get_fips_by_latlong(lat, long)
      now = DateTime.utc_now()
      al = alert_limit()
      oldest_alert = get_alert(oldest_id)
      inserted_at = oldest_alert.inserted_at

      query =
        from a in Alert,
          join: c in County, on: c.alert_id == a.id,
          where: c.fips_code in ^fips_codes and a.expires > ^now and a.inserted_at < ^inserted_at,
          distinct: a.id,
          order_by: [desc: a.inserted_at],
          limit: ^al,
          select: a

      Repo.all(query)
    end
  end

  # gets the historical alerts for the given lat and long
  def get_historical_by_latlong(lat, long) do
    if lat == "undefined" || long == "undefined" do
      []
    else
      fips_codes = Locations.get_fips_by_latlong(lat, long)
      now = DateTime.utc_now()
      al = alert_limit()

      query =
        from a in Alert,
          join: c in County, on: c.alert_id == a.id,
          where: c.fips_code in ^fips_codes and a.expires <= ^now,
          distinct: a.id,
          order_by: [desc: a.inserted_at],
          limit: ^al,
          select: a

      Repo.all(query)
    end
  end

  # gets the next chunk of older historical alerts for the given lat and long
  def get_older_historical_by_latlong(lat, long, oldest_id) do
    if lat == "undefined" || long == "undefined" || oldest_id == "undefined" do
      []
    else
      fips_codes = Locations.get_fips_by_latlong(lat, long)
      now = DateTime.utc_now()
      al = alert_limit()
      oldest_alert = get_alert(oldest_id)
      inserted_at = oldest_alert.inserted_at

      query =
        from a in Alert,
          join: c in County, on: c.alert_id == a.id,
          where: c.fips_code in ^fips_codes and a.expires <= ^now and a.inserted_at < ^inserted_at,
          distinct: a.id,
          order_by: [desc: a.inserted_at],
          limit: ^al,
          select: a

      Repo.all(query)
    end
  end

  @doc """
  Gets a single alert.

  Raises `Ecto.NoResultsError` if the Alert does not exist.

  ## Examples

      iex> get_alert!(123)
      %Alert{}

      iex> get_alert!(456)
      ** (Ecto.NoResultsError)

  """
  def get_alert!(id), do: Repo.get!(Alert, id)

  def get_alert(id), do: Repo.get(Alert, id)

  def get_alert_by_identifier(identifier) do
    Repo.get_by(Alert, identifier: identifier)
  end

  @doc """
  Creates a alert.

  ## Examples

      iex> create_alert(%{field: value})
      {:ok, %Alert{}}

      iex> create_alert(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_alert(attrs \\ %{}) do
    %Alert{}
    |> Alert.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a alert.

  ## Examples

      iex> update_alert(alert, %{field: new_value})
      {:ok, %Alert{}}

      iex> update_alert(alert, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_alert(%Alert{} = alert, attrs) do
    alert
    |> Alert.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Alert.

  ## Examples

      iex> delete_alert(alert)
      {:ok, %Alert{}}

      iex> delete_alert(alert)
      {:error, %Ecto.Changeset{}}

  """
  def delete_alert(%Alert{} = alert) do
    Repo.delete(alert)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking alert changes.

  ## Examples

      iex> change_alert(alert)
      %Ecto.Changeset{source: %Alert{}}

  """
  def change_alert(%Alert{} = alert) do
    Alert.changeset(alert, %{})
  end

  alias Stormchat.Alerts.County

  @doc """
  Returns the list of counties.

  ## Examples

      iex> list_counties()
      [%County{}, ...]

  """
  def list_counties do
    Repo.all(County)
  end

  # returns a list of fips codes affected by the given alert
  def get_affected_fips(alert_id) do
    query =
      from c in County,
        where: c.alert_id == ^alert_id,
        select: c.fips_code

    Repo.all(query)
  end

  @doc """
  Gets a single county.

  Raises `Ecto.NoResultsError` if the County does not exist.

  ## Examples

      iex> get_county!(123)
      %County{}

      iex> get_county!(456)
      ** (Ecto.NoResultsError)

  """
  def get_county!(id), do: Repo.get!(County, id)

  @doc """
  Creates a county.

  ## Examples

      iex> create_county(%{field: value})
      {:ok, %County{}}

      iex> create_county(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_county(attrs \\ %{}) do
    %County{}
    |> County.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a county.

  ## Examples

      iex> update_county(county, %{field: new_value})
      {:ok, %County{}}

      iex> update_county(county, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_county(%County{} = county, attrs) do
    county
    |> County.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a County.

  ## Examples

      iex> delete_county(county)
      {:ok, %County{}}

      iex> delete_county(county)
      {:error, %Ecto.Changeset{}}

  """
  def delete_county(%County{} = county) do
    Repo.delete(county)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking county changes.

  ## Examples

      iex> change_county(county)
      %Ecto.Changeset{source: %County{}}

  """
  def change_county(%County{} = county) do
    County.changeset(county, %{})
  end
end
