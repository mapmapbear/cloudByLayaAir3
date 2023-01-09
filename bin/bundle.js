
function __decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function")
        r = Reflect.decorate(decorators, target, key, desc);
    else
        for (let i = decorators.length - 1; i >= 0; i--)
            if (d = decorators[i])
                r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}

function __metadata(k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") {
        return Reflect.metadata(k, v);
    }
}

var _regClass = window._regClass;
var _dummyRegClass = Laya.regClass();
function __$decorate(assetId, codePath) {
    return function(...args) {
        if(args[0][0] == _dummyRegClass) {
            if(_regClass)
                args[0][0] = _regClass(assetId, codePath);
            else
                args[0][0] = function(constructor) { Laya.ClassUtils.regClass(assetId, constructor); };
        }
        return __decorate(...args);
    }
}

(() => {
  var __defProp = Object.defineProperty;
  var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

  // ../Documents/Cloud/src/Main.ts
  var __decorate = __$decorate("7bad1742-6eed-4d8d-81c0-501dc5bf03d6", "../src/Main.ts");
  var { regClass, property } = Laya;
  var Main = /* @__PURE__ */ __name(class Main2 extends Laya.Script {
    onStart() {
      console.log("Game start");
    }
  }, "Main");
  Main = __decorate([
    regClass()
  ], Main);
})();
//# sourceMappingURL=bundle.js.map
