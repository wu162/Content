import Ra3BattleNet.ResourcePatcher;

class Ra3BattleNet.Main {
    public function Main(apt: MovieClip) {

        trace("LOAD SPLASH");
        var splash = apt.createEmptyMovieClip("Ra3BattleNet_Splash", 1);
        trace("SPLASH " + splash);
        splash.loadMovie("Ra3BattleNet_Splash.swf");
        trace("SPLASH " + splash + " LOADED");

        var virtualList = apt.createEmptyMovieClip("Ra3BattleNet_VirtualList", 3);
        trace("VIRTUAL LIST " + virtualList);
        virtualList.loadMovie("Ra3BattleNet_VirtualList.swf");
        trace("VIRTUAL LIST " + virtualList + " LOADED");
        virtualList._visible = false;

        trace("LOAD CONNECTION INFORMATION");
        var connectionInformation = apt.createEmptyMovieClip("Ra3BattleNet_ConnectionInformation", 3);
        trace("CONNECTION INFORMATION " + connectionInformation);
        connectionInformation.loadMovie("Ra3BattleNet_ConnectionInformation.swf");
        trace("CONNECTION INFORMATION " + connectionInformation + " LOADED");

        trace("ADD MESSAGE HANDLER FOR RESOURCE PATCHER");
        _global.gMH.addPriorityMessageHandler(function(messageCode) {
            switch (messageCode) {
                case _global.MSGCODE.FE_MP_UPDATE_GAME_SETTINGS:
                    return ResourcePatcher.tryPatchGameSetupBase();
            }
        }, 1);

        trace("CREATE SEND MESSAGE FUNCTION");
        apt.sendMessage = function(message, chatMode, isHostOnly) {
            if (isHostOnly == "1") {
                var ret = new Object();
                loadVariables("QueryGameEngine?IsPcGameHost", ret);
                if (ret.IsPcGameHost != "1") {
                    return;
                }
            }
            fscommand("CallGameFunction", "%SendChatMessage?ChatText=" + message + "|ChatMode=" + chatMode);
        };
    }
}