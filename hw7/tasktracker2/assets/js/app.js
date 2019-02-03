// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import $ from "jquery";
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
function init_begin(){
  if(!$('#begin-bttn')){return;}
  let rows=$(".blk-row")
  for(let i=0;i<rows.length;i++){
    let blk_id=$(rows[i]).attr('id').substr(1)
    $(rows[i]).append("<td>" + 
     "<span><button onclick='ed_begin(" + blk_id + ")' class='btn btn-primary btn-xs'>Change Start Time</button></span>" +
     "<span><button onclick='ed_fin(" + blk_id + ")' class='btn btn-primary btn-xs'>Change End Time</button></span>" +
     "<span><button onclick='del_blk(" + blk_id + ")' class='btn btn-danger btn-xs'>Delete Task</button></span>" +
     "</span></td>")}
  $("#begin-bttn").click(bclick);
}

function begin(task_id){
  let text=JSON.stringify({
    timeblock:{startTime: Date.now(),
      endTime: Date.now(),
      task_id: task_id
    },
  })
  $.ajax(begin_path,{
    method: "post",
    dataType: "json",
    contentType: "application/json;charset=UTF-8",
    data: text,
    success: (resp)=>{st_bttn(resp.data.id)},
  });
}

function st_bttn(blk_id){
  let btn=$("#begin-bttn")
  if(!btn.data("begin")){
    btn.data("begin",true);
    btn.data("blk_id",blk_id)
  } 
  else{
    btn.data("begin",false);
    gtBlk(blk_id);
  }updt_bttn();
}

function fin(blk_id){
  let text=JSON.stringify({
    timeblock:{endTime: Date.now()
    },
  })
  $.ajax(begin_path + "/" + blk_id,{
    method: "put",
    dataType: "json",
    contentType: "application/json;charset=UTF-8",
    data: text,
    success: (resp)=>{st_bttn(resp.data.id)},
  })
}

function updt_bttn(){
  let btn=$("#begin-bttn")
  if(!btn.data("begin")){
    btn.text("Start Working")
    btn.attr('class','btn btn-primary')
  } 
  else{
    btn.text("Stop Working")
    btn.attr('class','btn btn-warning')
  }
}

function shwBlk(data){
  let startTime=data.startTime;
  let begin_std=new Date(startTime).toISOString().substr(0,19).replace("T"," ")
  let endTime=data.endTime;
  let fin_std=new Date(endTime).toISOString().substr(0,19).replace("T"," ")
  let sminutes=Math.floor(((endTime-startTime)/1000/60)<<0);
  let stime=sminutes + "minutes "
  let itm="<tr class='blk-row' id='b" + data.id + "'><td><strong>" + begin_std + "</strong></td><td><strong>" + fin_std + "</strong></td><td><strong>" + stime  + "</strong></td><td>" +
          "<span><button onclick='ed_begin(" + data.id + ")' class='btn btn-primary btn-xs'>Change Start Time</button></span>" +
          "<span><button onclick='ed_fin(" + data.id + ")' class='btn btn-primary btn-xs'>Change End Time</button></span>" +
          "<span><button onclick='del_blk(" + data.id + ")' class='btn btn-danger btn-xs'>Delete Task</button></span>" +"</td></tr>"
  $("#blks").append(itm)
}

function gtBlk(blk_id){
  $.ajax(begin_path + "/" + blk_id,{
    method: "get",
    dataType: "json",
    contentType: "application/json;charset=UTF-8",
    data: "",
    success: (resp)=>{shwBlk(resp.data)},
  })
}

window.del_blk=function(blk_id){$.ajax(begin_path + "/" + blk_id,{method: "delete",
    dataType: "json",
    contentType: "application/json;charset=UTF-8",
    data: "",
    success: (resp)=>{$("#b" + blk_id).remove()},
  })
}

window.ed_fin=function(blk_id){$("#ed-blk").append("<div class='row'>" +
  "<div class='col-9'><label for='fin-time-input'>Task End Time (Input Format: YYYY-MM-DD HH:MM:SS)</label>" +
  "<input type='text' id='fin-time-input' class='form-control'></div>" + "<div class='col-3'><button class='btn btn-primary btn-lg' onclick='updt_fin(" + blk_id + ")'>Change</button><button class='btn btn-secondary btn-lg' onclick='location.reload()'>Cancel</button></div>" + "</div>")
}

window.ed_begin=function(blk_id){$("#ed-blk").append("<div class='row'>" +
  "<div class='col-9'><label for='begin-time-input'>Task Start Time (Input Format: YYYY-MM-DD HH:MM:SS)</label>" +
  "<input type='text' id='begin-time-input' class='form-control'></div>"+ "<div class='col-3'><button class='btn btn-primary btn-lg' onclick='updt_begin(" + blk_id + ")'>Change</button><button class='btn btn-secondary btn-lg' onclick='location.reload()'>Cancel</button></div>" + "</div>")
}

window.updt_begin=function(blk_id){let begin_val=$("#begin-time-input").val();
  let date=new Date(""+begin_val)
  if (isNaN(date.getTime())){$("#warning").append("<p>Invalid Input Format</p>")
  }
  let text=JSON.stringify({timeblock:{startTime: date.getTime()-1000*60*60*5
    },
  })
  $.ajax(begin_path + "/" + blk_id,{
    method: "put",
    dataType: "json",
    contentType: "application/json;charset=UTF-8",
    data: text,
    success: (resp)=>{location.reload()},
  })
}

function bclick(x){
  let btn=$(x.target);
  if(!btn.data("begin")){begin(task_id)
  }
  else{fin(btn.data("blk_id"))
  }
}

window.updt_fin=function(blk_id){let fin_val=$("#fin-time-input").val();
  let date=new Date(""+fin_val)
  if(isNaN(date.getTime())){$("#warning").append("<p>Invalid Input Format</p>")
  }let text = JSON.stringify({
    timeblock:{endTime: date.getTime()-1000*60*60*5
    },
  })
  $.ajax(begin_path + "/" + blk_id,{
    method: "put",
    dataType: "json",
    contentType: "application/json;charset=UTF-8",
    data: text,
    success: (resp)=>{location.reload()},
  })
}

window.time_blk=function(){console.log("click!!!")
  let begin_val=$("#begin-time").val();
  let beginDate=new Date("" + begin_val);
  let fin_val=$("#fin-time").val();
  let finDate=new Date("" + fin_val);
  if(isNaN(beginDate.getTime()) || isNaN(finDate.getTime())){
    $("#time-warning").css("color","red")
    $("#time-warning").text("Invalid Input Format")
  }
  let text=JSON.stringify({
    timeblock:{
      startTime: beginDate.getTime(),
      endTime: finDate.getTime(),
      task_id: task_id
    },
  })
  $.ajax(begin_path,{
    method: "post",
    dataType: "json",
    contentType: "application/json;charset=UTF-8",
    data: text,
    success: (resp)=>{
      $("#begin-time").val("")
      $("#fin-time").val("")
      $("#time-warning").css("color","green")
      $("#time-warning").text("Time Added")
      shwBlk(resp.data)
     },
  });
}

$(init_begin)
