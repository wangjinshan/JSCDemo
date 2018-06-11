/**
 * Created by shange on 2017/4/13.
 */

function SMSDK()
{
    var name = "金山";
    this.initSDK = function (hello)
    {
        var initData ={};
        var appkey =
            {
            "appkey": hello
            }
        var appSecrect=
            {
            "appSecrect": hello
            }
        initData["appkey"] = appkey;
        initData["appSecrect"] = appSecrect;z
        return initData;
    };
    
    this.getCode = function ()
    {
        var phoneNum = document.getElementById('phoneInput').value;
        return phoneNum;
    };
    this.commitCode = function ()
    {
        var code = document.getElementById('codeInput').value;
        return code;
    };
    this.getCodeCallBack = function(message)
    {
        var p3 = document.createElement('p');
        p3.innerText = message;
        document.body.appendChild(p3);
    }
    this.commitCodeCallBack = function(message)
    {
        var p3 = document.createElement('p');
        p3.innerText = message;
        document.body.appendChild(p3);
    }
    
    function ocTest(num,msg)
    {
        document.getElementById('msg').innerHTML = '这是我的手机号:' + num + ',' + msg + '!!'
    }
    
}
var $smsdk = new SMSDK();











