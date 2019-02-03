defmodule Calc do
  #@moduledoc """
  #Documentation for Calc.
  #"""

  #@doc """
  #Hello world.

  ## Examples

   #   iex> Calc.hello
   #   :world

  #"""
  #def hello do
  #  :world
  #end

#Will parse and evaluate an arithmetic expression
def eval(arg) do
	if String.contains?(arg,".") do
		"Please enter an integer"
	else
	exp=split(arg)
	cond do
		List.first(exp)=="-"->eval1(exp,[0],[])
		true->eval1(exp,[],[])
	end
	end
end

#Will parse and evaluate an arithmetic expression
def eval1(exp,dig,sym) do
	cond do
		length(exp)>0->[init|exp]=exp
		cond do
			number(init)->{digs,fraction}=Integer.parse(init)
			dig=dig++[digs]
			init=="("->if List.first(exp)=="-" do
				exp=List.delete_at(exp,0)
				exp=List.update_at(exp,0,&("-"<>&1))
			end
			sym=sym++[init]
			init==")"->{dig,sym}=handle_brck(dig,sym)
			init=="+"||init=="*"||init=="/"||init=="-"->{dig,sym}=handle_op(dig,sym,init)
			true->
		end
		eval1(exp,dig,sym)
		length(exp)==0&&length(sym)>0->{dig,sym}=ope(dig,sym)
		eval1(exp,dig,sym)
		length(exp)==0&&length(sym)==0->List.first(dig)
	end
end

#checks whether the input is number
def number(a) do
	cond do
		String.first(a)=="-"&&String.length(a)>1->true
		a>="0"->true
		true->false		
	end
end

#splits up the given input into single values
def split(arg) do
	arg
	|>String.codepoints()
	|>Enum.filter(&(&1!=" "))
	|>Enum.chunk_by(&(&1>="0"))
	|>Enum.map(&(List.to_string(&1)))
	|>Enum.map(&(divd(&1)))
	|>List.flatten()
end

#Performs the various arithmetic operations
def opt(symbol,n2,n1) do
	cond do
		symbol=="/"->Integer.floor_div(n1,n2)
		symbol=="*"->n1*n2
		symbol=="-"->n1-n2
		symbol=="+"->n1+n2
		true->
	end
end

def divd(a) do
	cond do
		String.length(a)>1&&a<="0"->String.codepoints(a)
		true->a
	end
end

#Handles bracket 
def handle_brck(dig,sym) do
	cond do
		List.last(sym)!="("->{dig,sym}=ope(dig,sym)
		handle_brck(dig,sym)
		true->{symbol,sym}=List.pop_at(sym,-1)
		{dig,sym}
	end
end

#Checks for priority of arithmetic operators
def impt(fir,initial) do
	cond do
		initial=="("->false
		(initial=="-"||initial=="+")&&(fir=="/"||fir=="*")->false
		true->true
	end
end

#Handles operators
def handle_op(dig,sym,fir) do
	cond do
		length(sym)>0&&impt(fir,List.last(sym))->{dig,sym}=ope(dig,sym)
		handle_op(dig,sym,fir)
		true->sym=sym++[fir]
		{dig,sym}
	end
end

#Pops from the stack
def ope(dig,sym) do
	{n1,dig}=List.pop_at(dig,-1)
	{n2,dig}=List.pop_at(dig,-1)
	{symbol,sym}=List.pop_at(sym,-1)
	dig=dig++[opt(symbol,n1,n2)]
	{dig,sym}
end

#Will repeatedly print a prompt, read one line, evaluate it, and print the result
def main() do
	case IO.gets("Enter the mathematical expression: ") do
	arg->IO.puts(eval(arg))
	main()
end
end
end
