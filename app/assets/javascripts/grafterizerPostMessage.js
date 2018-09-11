'use strict';

(function(scope){
    var channel = 'datagraft-post-message';
    var currentState;
    var currentParams;
    function Grafterizer(transformationPath, htmlElement, origin) {
        this._stuffToDo = [];
        this._stuffToDoAtEveryConnection = [];
        this.origin = origin;
        this.transformationPath = transformationPath;
        this._createIframe(htmlElement);
        this._sendMessageWindow = window;
        this._savedAuthorization = null;

        var _this = this;
        this.connected = false;
        window.addEventListener('message', function(event) {
            if (event.origin !== origin) return;
            var data = event.data;
            if (!data || !data.channel || data.channel !== channel) return;
            if (data.message === 'ready') {
                console.log("ready")
               _this.connected = true;
               _this._sendMessageWindow = event.source;
               _this._onReady();
            } else if (data.message === 'set-location') {
                window.location = data.location;
            } else if (data.message === 'get-state-and-params') {
                _this.sendMessage({
                    message: 'get-state-and-params',
                    state: _this.currentState,
                    toParams: _this.currentParams,
                    channel: channel
                }, false);
            }
        }, false);
    };

    Grafterizer.prototype.hideFooter = function() {
        for (var f = document.getElementsByTagName('footer'), i = 0, l = f.length; i < l;++i) {
            f[i].style.display = 'none';
        }
    };

    Grafterizer.prototype._createIframe = function(htmlElement) {
        var iframe = document.createElement('iframe');
        iframe.className = 'grafterizer';
        iframe.src = this.transformationPath;
        htmlElement.appendChild(iframe);
    };

    Grafterizer.prototype._onReady = function() {
        // this.setAuthorization(this._savedAuthorization);
        for (a = this._stuffToDoAtEveryConnection, i = 0, l = a.length; i < l; ++i) {
            this.sendMessage(a[i]);
        }
        for (var a = this._stuffToDo, i = 0, l = a.length; i < l; ++i) {
            this.sendMessage(a[i]);
        }
        this._stuffToDo = [];
    };

    Grafterizer.prototype.sendMessage = function(message, everyConnection) {
        if (everyConnection) {
            this._stuffToDoAtEveryConnection.push(message);
        }

        if (!this.connected) {
            if (!everyConnection) {
                this._stuffToDo.push(message);
            }
            return this;
        }

        if (message !== Object(message)) {
            message = {content: message};
        }

        message.channel = channel;
        this._sendMessageWindow.postMessage(message, this.transformationPath);
        return this;
    };

    Grafterizer.prototype.go = function(state, toParams, everyConnection) {
        this.currentState = state;
        this.currentParams = toParams;
        return this.sendMessage({
            message: 'state.go',
            state: state,
            toParams: toParams
        }, everyConnection);
    };

    Grafterizer.prototype.setAuthorization = function(keypass) {
        this._savedAuthorization = keypass;
        if (this.connected) {
            return this.sendMessage({
                message: 'set-authorization',
                keypass: keypass
            });
        }
        return this;
    };

    scope.Grafterizer = Grafterizer;

})(window);
