﻿import Ra3BattleNet.Utils;

class Ra3BattleNet.AutoMatchHelper {
    private static var CLASS_NAME: String = "Ra3BattleNet.AutoMatchHelper";
    private static var RANKED_CHECKBOX: String = "rankedCheckBox";
    private static var RANKED_CHECKBOX_OFFSET_Y: Number = -30;
    private static var RANKED_LABEL_OFFSET_X: Number = 22.5;
    private static var RANKED_LABEL_OFFSET_Y: Number = -11.5;
    private static var RANKED_DETAILS_OFFSET_X: Number = 0;
    private static var RANKED_DETAILS_OFFSET_Y: Number = -5;
    private static var RANKED_DETAILS_WIDTH: Number = 500;
    private static var RANKED_DETAILS_HEIGHT: Number = 60;
    private static var AUTOMATCH_SEARCH_DETAILS: String = "Ra3BattleNet_AutoMatchHelper_AutomatchSearchDetails";
    private static var AUTOMATCH_SEARCH_DETAILS_X: Number = -491.5;
    private static var AUTOMATCH_SEARCH_DETAILS_Y: Number = -244.9;
    private static var AUTOMATCH_SEARCH_DETAILS_WIDTH: Number = 979.5;
    private static var AUTOMATCH_SEARCH_DETAILS_HEIGHT: Number = 55.95;
    private static var _apt: MovieClip;
    private static var _intervalId: Number;

    public function AutoMatchHelper(thisApt: MovieClip) {
        var TRACE_PREFIX: String = "[" + CLASS_NAME + "::AutoMatchHelper] ";
        if (typeof _apt === "movieclip") {
            trace(TRACE_PREFIX + "already initialized");
            return;
        }
        _apt = thisApt;

        trace(TRACE_PREFIX + "running on " + _apt);
        if (!createElements()) {
            trace(TRACE_PREFIX + "failed to create elements");
            return;
        }
        setInterval(update, 500);
        // 下面这代码实在是太诡异了，但也只能这样了
        // 我们必须依靠这段代码才能在我们“寄生”的 screen 退出时，把自己 unload 掉
        _global.gSM.setOnExitScreen(_global.bind1(this, function(previousOnExitScreen: Function) {
            unload();
            if(String(previousOnExitScreen) == "[function]" || previousOnExitScreen != null) {
                trace("[" + CLASS_NAME + "::onExitScreen] calling previous onExitScreen");
                previousOnExitScreen.call(_global.gSM);
            }
        }, _global.gSM.m_onExitScreenFunc));
    }

    private static function unload(): Void {
        trace("[" + CLASS_NAME + "::unload] apt unloading");
        clearInterval(_intervalId);
        _apt.removeMovieClip();
        delete _intervalId;
        delete _apt;
        delete _global.Ra3BattleNet.AutoMatchHelper;
        trace("[" + CLASS_NAME + "::unload] apt unloaded");
    }

    public static function update(): Void {
        var TRACE_PREFIX: String = "[" + CLASS_NAME + "::update] ";
        if (typeof _apt !== "movieclip") {
            trace(TRACE_PREFIX + "apt is not a movieclip");
            return;
        }
        var autoMatchSetup = _apt._parent;
        if (typeof autoMatchSetup !== "movieclip") {
            trace(TRACE_PREFIX + "autoMatchSetup is not a movieclip");
            return;
        }
        var inviteButton: MovieClip = autoMatchSetup.inviteButton;
        if (inviteButton.isEnabled()) {
            _apt._visible = false;
            inviteButton._alpha = 100;
        }
        else {
            _apt._visible = true;
            inviteButton._alpha = 0;

            var rankedCheckBox: MovieClip = _apt[RANKED_CHECKBOX];
            if (rankedCheckBox.isEnabled() === false) {
                trace(TRACE_PREFIX + "ranked checkbox does not have value, request it");
                var result: Object = new Object();
                loadVariables("Ra3BattleNet_InGameHttpRequest", result);
                updateRankedCheckBox(rankedCheckBox, result["isCurrentPlayerRanked"]);
            }
        }
    }

    private static function createElements(): Boolean {
        var TRACE_PREFIX: String = "[" + CLASS_NAME + "::createElements] ";
        if (typeof _apt !== "movieclip") {
            trace(TRACE_PREFIX + "apt is not a movieclip");
            return;
        }
        var autoMatchSetup: MovieClip = _apt._parent;
        if (typeof autoMatchSetup !== "movieclip") {
            trace(TRACE_PREFIX + "autoMatchSetup is not a movieclip");
            return;
        }
        var autoMatchPanel: MovieClip = autoMatchSetup._parent;
        if (typeof autoMatchPanel !== "movieclip") {
            trace(TRACE_PREFIX + "autoMatchPanel is not a movieclip");
            return;
        }
        var originalCheckBox: MovieClip = autoMatchSetup.broadcastCheckBox;
        if (typeof originalCheckBox !== "movieclip") {
            trace(TRACE_PREFIX + "original broadcast checkbox is not a movieclip");
            return false;
        }
        var autoMatchLobby: MovieClip = autoMatchPanel.autoMatchLobby;
        if (typeof autoMatchLobby !== "movieclip") {
            trace(TRACE_PREFIX + "autoMatchLobby is not a movieclip");
            return false;
        }
        var autoMatchLobbyCommander: MovieClip = autoMatchLobby.mcCommanderPlayer;
        if (typeof autoMatchLobbyCommander !== "movieclip") {
            trace(TRACE_PREFIX + "autoMatchLobbyCommander is not a movieclip");
            return false;
        }
        var originalLabel: MovieClip = autoMatchLobbyCommander.tfBroadcast;
        if (typeof originalLabel !== "movieclip") {
            trace(TRACE_PREFIX + "original broadcast label is not a movieclip");
            return false;
        }
        var originalDrop: TextField = originalLabel.drop;
        var originalTop: TextField = originalLabel.top;
        if (!originalDrop || !originalTop) {
            trace(TRACE_PREFIX + "original broadcast label does not have drop and top text fields");
            return false;
        }

        trace(TRACE_PREFIX + "creating elements on " + _apt);
        var newCheckbox: MovieClip = _apt.attachMovie(
            "std_MouseCheckBoxSymbol",
            RANKED_CHECKBOX,
            _apt.getNextHighestDepth(), {
                m_width: 200,
                m_textAlign: false,
                m_labelPosition: "right align",
                m_label_x: 0,
                m_label_y: 0,
                m_focusDirs: "Up/Down",
                m_iconType: "default",
                m_extLabel: "",
                m_nTruncateType: 0,
                m_label: "",
                m_bEnabled: true,
                m_refFM: "_root.gFM",
                m_initiallySelected: false,
                m_tabIndex: 1,
                m_bVisible: true,
                m_contentSymbol: "checkBoxContentClipSymbol"
            }
        );
        newCheckbox._x = originalCheckBox._x;
        newCheckbox._y = originalCheckBox._y + originalCheckBox._height + RANKED_CHECKBOX_OFFSET_Y;
        newCheckbox.disable();
        newCheckbox.setOnMouseDownFunction(function () {
            var parameters: String = "?setCurrentPlayerRanked=" + (newCheckbox.isChecked() ? "1" : "0");
            var result: Object = new Object();
            loadVariables("Ra3BattleNet_InGameHttpRequest" + parameters, result);
            updateRankedCheckBox(newCheckbox, result["isCurrentPlayerRanked"]);
        });

        var label: MovieClip = _apt.createEmptyMovieClip(
            "rankedCheckBoxLabel", 
            _apt.getNextHighestDepth()
        );
        label._x = newCheckbox._x + RANKED_LABEL_OFFSET_X;
        label._y = newCheckbox._y + RANKED_LABEL_OFFSET_Y;
        label.createTextField("drop", 1, originalDrop._x, originalDrop._y, originalDrop._width, originalDrop._height);
        label.createTextField("top", 2, originalTop._x, originalTop._y, originalTop._width, originalTop._height);
        var drop: TextField = label.drop;
        var top: TextField = label.top;
        drop.textColor = originalDrop.textColor;
        top.textColor = originalTop.textColor;
        // 红警3没有 setNewTextFormat，只有 setTextFormat
        drop.setTextFormat(originalDrop.getNewTextFormat());
        top.setTextFormat(originalTop.getNewTextFormat());
        drop.text = top.text = "$IsPersonaRankedLabel";
        top.text += "&Outline"

        _apt.createTextField(
            "rankedCheckBoxDetails", 
            _apt.getNextHighestDepth(),
            label._x + RANKED_DETAILS_OFFSET_X,
            label._y + label._height + RANKED_DETAILS_OFFSET_Y,
            RANKED_DETAILS_WIDTH,
            RANKED_DETAILS_HEIGHT
        );
        var details: TextField = _apt["rankedCheckBoxDetails"];
        details.setTextFormat(new TextFormat("Lucida Sans Unicode", 14, top.textColor));
        details.wordWrap = true;
        details.text = "$IsPersonaRankedDetails";
        trace(TRACE_PREFIX + "created elements on " + _apt);

        // 给搜索框也加个文本框
        trace(TRACE_PREFIX + "creating textfield on autoMatchSearch");
        var autoMatchSearch: MovieClip = autoMatchPanel.autoMatchSearch;
        if (typeof autoMatchSearch !== "movieclip") {
            trace(TRACE_PREFIX + "autoMatchSearch is not a movieclip");
            return false;
        }

        autoMatchSearch.createTextField(
            AUTOMATCH_SEARCH_DETAILS, 
            autoMatchSearch.getNextHighestDepth(),
            AUTOMATCH_SEARCH_DETAILS_X,
            AUTOMATCH_SEARCH_DETAILS_Y + 7,
            AUTOMATCH_SEARCH_DETAILS_WIDTH,
            AUTOMATCH_SEARCH_DETAILS_HEIGHT
        );
        var searchDetails: TextField = autoMatchSearch[AUTOMATCH_SEARCH_DETAILS];
        searchDetails.textHeight = 22;
        searchDetails.textColor = 0xFE8101;
        searchDetails.setTextFormat(new TextFormat("Red Alert", 22));
        searchDetails.autoSize = "center";
        searchDetails.text = "$AUTOMATCHSEARCHHEADER";
        trace(TRACE_PREFIX + "created textfield on autoMatchSearch");
        return true;
    }

    private static function updateRankedCheckBox(checkBox: MovieClip, isRanked): Void {
        trace("[" + CLASS_NAME + "::updateRankedCheckBox] isRanked = " + isRanked);
        if (isRanked === "1") {
            checkBox.enable();
            checkBox.check();
        }
        else if (isRanked === "0") {
            checkBox.enable();
            checkBox.unCheck();
        }
        else {
            checkBox.disable();
        }
    }
}
