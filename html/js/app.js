$(document).on('keydown', function() { //Don't Touch This
    switch(event.keyCode) {
        case 27:
            break;
    }
});

var moneyTimeout = null;
var CurrentProx = 0;

// MONEY HUD

(() => {
    Config = {};
    Config.Update = function(data) {
        if(data.type == "cash") {
            $(".money-cash").css("display", "block");
            $("#cash").html(data.cash);
            if (data.minus) {
                $(".money-cash").append('<p class="moneyupdate minus">-<span id="cash-symbol">&dollar;&nbsp;</span><span><span id="minus-changeamount">' + data.amount + '</span></span></p>')
                $(".minus").css("display", "block");
                setTimeout(function() {
                    $(".minus").fadeOut(750, function() {
                        $(".minus").remove();
                        $(".money-cash").fadeOut(750);
                    });
                }, 3500)
            } else {
                $(".money-cash").append('<p class="moneyupdate plus">+<span id="cash-symbol">&dollar;&nbsp;</span><span><span id="plus-changeamount">' + data.amount + '</span></span></p>')
                $(".plus").css("display", "block");
                setTimeout(function() {
                    $(".plus").fadeOut(750, function() {
                        $(".plus").remove();
                        $(".money-cash").fadeOut(750);
                    });
                }, 3500)
            }
        }
    };

    Config.Open = function(data) {
        $(".money-cash").css("display", "block");
        $("#cash").html(data.cash);
    };
    Config.Close = function() {
    };
    Config.Show = function(data) {
        if(data.type == "cash") {
            $(".money-cash").fadeIn(150);
            $("#cash").html(data.cash);
            setTimeout(function() {
                $(".money-cash").fadeOut(750);
            }, 3500)
        } 
    };

// PLAYER HUD

    Config.UpdateHud = function(data) {
        var Show = "block";
        if (data.show) {
            Show = "none";
            $(".ui-container").css("display", Show);
            return;
    }
            $(".ui-container").css("display", Show);

    // Voice & Highlight Circle

    Progress(data.talking, ".mic");
    if (data.speaking == 1) {
    $(".mic").css({"stroke":"yellow"}); 
    } else {
    $('.mic').css({"stroke":"#fff"});
    }

    Config.SetTalkingState = function(data) {
        if (!data.IsTalking) {
            $(".voice-block").animate({"background-color": "rgb(255, 255, 255)"}, 150);
        } else {
            $(".voice-block").animate({"background-color": "#fc4e03"}, 150);
        }
    }

    // Radio & Highlight Circle

    if (data.talking && data.radio) {
        $(".mic").css({"background-color": "#3467d4"});
    } else if (data.talking) {
        $(".mic").css({"background-color": "white"}); 
    } else {
        $(".mic").css({"background-color": "rgb(85, 85, 85)"}); 
    }

    // Health Circle

    Progress(data.health - 100, ".hp");
    if (data.health <= 195) {
        $('.hvida').fadeIn(3000);
    }
    if (data.health >= 196) {
        $('.hvida').fadeOut(3000);
    }
    if (data.health <= 145) {
        $('.vida').css("stroke", "red");
    } else {
        $('.vida').css("stroke", "#498949");
    }

    // Armor Circle

    Progress(data.armor, ".armor");
    if (data.armor <= 95) {
        $('.harmor').fadeIn(3000);
    }
    if (data.armor >= 96) {
        $('.harmor').fadeOut(3000);
    }
    if (data.armor <= 45) {
        $('.amr').css("stroke", "red");
    } else {
        $('.amr').css("stroke", "#2962FF");
    }

    // Hunger Circle

    Progress(data.hunger, ".hunger");
    if (data.hunger <= 95) {
        $('.hhunger').fadeIn(3000);
    }
    if (data.hunger >= 96) {
        $('.hhunger').fadeOut(3000);
    }
    if (data.hunger <= 45) {
        $('.fome').css("stroke", "red");
    } else {
        $('.fome').css("stroke", "#f0932b");
    }

    // Thirst Circle

    Progress(data.thirst, ".thirst");
    if (data.thirst <= 95) {
        $('.hthirst').fadeIn(3000);
    }
    if (data.thirst >= 96) {
        $('.hthirst').fadeOut(3000);
    }
    if (data.thirst <= 45) {
        $('.cede').css("stroke", "red");
    } else {
        $('.cede').css("stroke", "#3467d4");
    }

    // Stress Circle

    Progress(data.stress, ".stress");
    if (data.stress >= 3) {
        $('.hstress').fadeIn(3000);
    }
    if (data.stress <= 2) {
        $('.hstress').fadeOut(3000);
    }

// CAR HUD

    Config.CarHud = function(data) {
        if (data.show) {
            $(".ui-car-container").fadeIn();
            $(".hnitrous").fadeIn(3000);
        } else {
            $(".ui-car-container").fadeOut();
            $('.hnitrous').fadeOut(3000);
        }
    };

    // Seat Belt Circle

    Config.ToggleSeatbelt = function(data) {
        if (data.seatbelt) {
            $(".car-seatbelt-info img").fadeOut(750);
            $(".circle-harness").fadeIn(750);
        } else {
            $(".car-seatbelt-info img").fadeIn(750);
            $(".circle-harness").fadeOut(750);
        }
    };

    // Nitrous Circle

    Progress(data.nivel, ".nitrous");
    if (data.activo) {
    $(".nitrous").css({"stroke":"#fcb80a"});
    } else {
    $(".nitrous").css({"stroke":"rgb(241, 71, 185)"});
    }  

    // Engine Health

    if (data.engine <= 45) {
        $(".engine-red img").fadeIn(750);
        $(".engine-orange img").fadeOut(750);
    }
    else if (data.engine <= 75 && data.engine >= 46 ) {
        $(".engine-red img").fadeOut(750);
        $(".engine-orange img").fadeIn(750);
    } else {
        $(".engine-red img").fadeOut(750);
        $(".engine-orange img").fadeOut(750);
    }

    // Speed & Fuel Color Circle

    setProgressSpeed(data.speed, ".progress-speed");
    setProgressFuel(data.fuel, ".progress-fuel");
    if (data.fuel <= 20) {
        $('.progress-fuel').css("stroke", "red");
    } else if (data.fuel <= 30) {
        $('.progress-fuel').css("stroke", "orange");
    } else {
        $('.progress-fuel').css("stroke", "#fff");
    }
};

// NAVIGATION VISIBILITY

window.addEventListener("message", function (event) {
    if (event.data.action == "display") {
        type = event.data.type
        value = event.data.value
        if (type === null) {
            $(".street").hide();
            $(".compass").hide();
        } else  {
            $('.street').html(type);
            $(".street").show();
            $('.compass').html(value);
            $(".compass").show();
            if (value  !== undefined) {
                bar = document.getElementsByTagName("svg")[0];
                bar.setAttribute("viewBox", ''+ (value - 90) + ' 0 180 5');
                heading = document.getElementsByTagName("svg")[1];
                heading.setAttribute("viewBox", ''+ (value - 90) + ' 0 180 1.5');
            }
        }
        $(".ui").fadeIn();
    } else if (event.data.action == "hide") {
        $(".ui").fadeOut();
    }
});

// MINIMAP VISIBILITY

$(function() {
    window.addEventListener("message", function(event) {
        var data = event.data;
        switch (data.action) {
            case "displaySquareUI":
                $(".mapbordercircle").hide();
                $(".outline").show();
                $(".mapbordersquare").fadeIn(300);
            break;
            case "hideSquareUI":
                $(".mapbordercircle").hide();
                $(".outline").hide();
                $(".mapbordersquare").hide();
            break;
            case "displayCircleUI":
                $(".mapbordersquare").hide();
                $(".outline").show();
                $(".mapbordercircle").show();
            break;
            case "hideCircleUI":
                $(".mapbordersquare").hide();
                $(".outline").hide();
                $(".mapbordercircle").hide();
            break;
        }
    });
});

// ON LOAD

window.onload = function(e) {
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                Config.Open(event.data);
                break;
            case "close":
                Config.Close();
                break;
            case "update":
                Config.Update(event.data);
                break;
            case "show":
                Config.Show(event.data);
                break;
            case "hudtick":
                Config.UpdateHud(event.data);
                break;
            case "car":
                Config.CarHud(event.data);
                break;
            case "engine":
                Config.EngineHealth(event.data);
                break;
            case "seatbelt":
                Config.ToggleSeatbelt(event.data);
                break;
            case "nitrous":
                Config.UpdateNitrous(event.data);
                break;
            case "UpdateProximity":
                Config.UpdateProximity(event.data);
                break;
            case "talking":
                Config.SetTalkingState(event.data);
                break;
        }
    })
}

// Progress Circle

    function ProgressVoip(percent, element) {
        var circle = document.querySelector(element);
        var radius = circle.r.baseVal.value;
        var circumference = radius * 200 * Math.PI;
        circle.style.strokeDasharray = `${circumference} ${circumference}`;
        circle.style.strokeDashoffset = `${circumference}`;
        const offset = circumference - ((-percent * 100) / 100 / 100) * circumference;
        circle.style.strokeDashoffset = -offset;
    }
    function Progress(percent, element) {
        var circle = document.querySelector(element);
        var radius = circle.r.baseVal.value;
        var circumference = radius * 2 * Math.PI;
        circle.style.strokeDasharray = `${circumference} ${circumference}`;
        circle.style.strokeDashoffset = `${circumference}`;
        const offset = circumference - ((-percent * 100) / 100 / 100) * circumference;
        circle.style.strokeDashoffset = -offset;
    }
    function setProgressSpeed(value, element){
        var circle = document.querySelector(element);
        var radius = circle.r.baseVal.value;
        var circumference = radius * 2 * Math.PI;
        var html = $(element).parent().parent().find('span');
        var percent = value*100/450;
        circle.style.strokeDasharray = `${circumference} ${circumference}`;
        circle.style.strokeDashoffset = `${circumference}`;
        const offset = circumference - ((-percent*73)/100) / 100 * circumference;
        circle.style.strokeDashoffset = -offset;
        html.text(value);
      }
      function setProgressFuel(percent, element) {
        var circle = document.querySelector(element);
        var radius = circle.r.baseVal.value;
        var circumference = radius * 2 * Math.PI;
        var html = $(element).parent().parent().find("span");
        circle.style.strokeDasharray = `${circumference} ${circumference}`;
        circle.style.strokeDashoffset = `${circumference}`;
        const offset = circumference - ((-percent * 73) / 100 / 100) * circumference;
        circle.style.strokeDashoffset = -offset;
        html.text(Math.round(percent));
      }
})();

// RADIAL PROGRESS

function radialProgress(parent) {
    var _data=null,
        _duration= 1000,
        _selection,
        _margin = {top:0, right:0, bottom:30, left:0},
        __width = 300,
        __height = 300,
        _diameter = 150,
        _label="",
        _fontSize=10;
    var _mouseClick;
    var _value= 0,
        _minValue = 0,
        _maxValue = 100;
    var  _currentArc= 0, _currentArc2= 0, _currentValue=0;
    var _arc = d3.svg.arc()
        .startAngle(0 * (Math.PI/180)); //just radians
    var _arc2 = d3.svg.arc()
        .startAngle(0 * (Math.PI/180))
        .endAngle(0); //just radians
    _selection=d3.select(parent);

    function component() {
        _selection.each(function (data) {
            // Select the svg element, if it exists.
            var svg = d3.select(this).selectAll("svg").data([data]);
            var enter = svg.enter().append("svg").attr("class","radial-svg").append("g");
            measure();
            svg.attr("width", __width)
                .attr("height", __height);
            var background = enter.append("g").attr("class","component")
                .attr("cursor","pointer")
                .on("click",onMouseClick);
            _arc.endAngle(360 * (Math.PI/180))
            background.append("rect")
                .attr("class","background")
                .attr("width", _width)
                .attr("height", _height);
            background.append("path")
                .attr("transform", "translate(" + _width/2 + "," + _width/2 + ")")
                .attr("d", _arc);
            background.append("text")
                .attr("class", "label")
                .attr("transform", "translate(" + _width/2 + "," + (_width + _fontSize) + ")")
                .text(_label);
           var g = svg.select("g")
                .attr("transform", "translate(" + _margin.left + "," + _margin.top + ")");
            _arc.endAngle(_currentArc);
            enter.append("g").attr("class", "arcs");
            var path = svg.select(".arcs").selectAll(".arc").data(data);
            path.enter().append("path")
                .attr("class","arc")
                .attr("transform", "translate(" + _width/2 + "," + _width/2 + ")")
                .attr("d", _arc);
            //Another path in case we exceed 100%
            var path2 = svg.select(".arcs").selectAll(".arc2").data(data);
            path2.enter().append("path")
                .attr("class","arc2")
                .attr("transform", "translate(" + _width/2 + "," + _width/2 + ")")
                .attr("d", _arc2);
            enter.append("g").attr("class", "labels");
            var label = svg.select(".labels").selectAll(".label").data(data);
            label.enter().append("text")
                .attr("class","label")
                .attr("y",_width/2+_fontSize/3)
                .attr("x",_width/2)
                .attr("cursor","pointer")
                .attr("width",_width)
                // .attr("x",(3*_fontSize/2))
                .text(function (d) { return Math.round((_value-_minValue)/(_maxValue-_minValue)*100) + "%" })
                .style("font-size",_fontSize+"px")
                .on("click",onMouseClick);
            path.exit().transition().duration(500).attr("x",1000).remove();
            layout(svg);
            function layout(svg) {
                var ratio=(_value-_minValue)/(_maxValue-_minValue);
                var endAngle=Math.min(360*ratio,360);
                endAngle=endAngle * Math.PI/180;
                path.datum(endAngle);
                path.transition().duration(_duration)
                    .attrTween("d", arcTween);
                if (ratio > 1) {
                    path2.datum(Math.min(360*(ratio-1),360) * Math.PI/180);
                    path2.transition().delay(_duration).duration(_duration)
                        .attrTween("d", arcTween2);
                }
                label.datum(Math.round(ratio*100));
                label.transition().duration(_duration)
                    .tween("text",labelTween);
            }
        });
        function onMouseClick(d) {
            if (typeof _mouseClick == "function") {
                _mouseClick.call();
            }
        }
    }
    function labelTween(a) {
        var i = d3.interpolate(_currentValue, a);
        _currentValue = i(0);

        return function(t) {
            _currentValue = i(t);
            this.textContent = Math.round(i(t)) + "%";
        }
    }
    function arcTween(a) {
        var i = d3.interpolate(_currentArc, a);

        return function(t) {
            _currentArc=i(t);
            return _arc.endAngle(i(t))();
        };
    }
    function arcTween2(a) {
        var i = d3.interpolate(_currentArc2, a);

        return function(t) {
            return _arc2.endAngle(i(t))();
        };
    }
    function measure() {
        _width=_diameter - _margin.right - _margin.left - _margin.top - _margin.bottom;
        _height=_width;
        _fontSize=_width*.2;
        _arc.outerRadius(_width/2);
        _arc.innerRadius(_width/2 * .85);
        _arc2.outerRadius(_width/2 * .85);
        _arc2.innerRadius(_width/2 * .85 - (_width/2 * .15));
    }
    component.render = function() {
        measure();
        component();
        return component;
    }
    component.value = function (_) {
        if (!arguments.length) return _value;
        _value = [_];
        _selection.datum([_value]);
        return component;
    }
    component.margin = function(_) {
        if (!arguments.length) return _margin;
        _margin = _;
        return component;
    };
    component.diameter = function(_) {
        if (!arguments.length) return _diameter
        _diameter =  _;
        return component;
    };
    component.minValue = function(_) {
        if (!arguments.length) return _minValue;
        _minValue = _;
        return component;
    };
    component.maxValue = function(_) {
        if (!arguments.length) return _maxValue;
        _maxValue = _;
        return component;
    };
    component.label = function(_) {
        if (!arguments.length) return _label;
        _label = _;
        return component;
    };
    component._duration = function(_) {
        if (!arguments.length) return _duration;
        _duration = _;
        return component;
    };
    component.onClick = function (_) {
        if (!arguments.length) return _mouseClick;
        _mouseClick=_;
        return component;
    }
    return component;
}
