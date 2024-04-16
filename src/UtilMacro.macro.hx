package;

import haxe.macro.Expr.ExprOf;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using tink.MacroApi;

class FutureArray_Use {
	//TODO add below additions to futurearray
	public static macro function add(futureArr:ExprOf<Util.FutureArray>, funcCall:Expr) {
		return macro $futureArr._add(Util.FutureArray.megaLazy(() -> $funcCall));
	}
}

class PromiseArray_Use {
	public static macro function add(promiseArr:ExprOf<Util.PromiseArray>, funcCall:Expr) {
		var typ = Context.typeof(funcCall);
		var promiseType = Context.getType("tink.core.Promise");
		var futureType = Context.getType("tink.core.Future");
		var void = Context.getType("Void");
		var promiseFunc = TFun([], promiseType);
		var futureFunc = TFun([], futureType);
		// TFun([],)
		return switch (typ) {
			case Context.unify(promiseFunc, _) => true:
				macro @:pos(Context.currentPos()) $promiseArr._add($funcCall);
			case Context.unify(futureFunc, _) => true:
				macro @:pos(Context.currentPos()) $promiseArr._add($funcCall);
			case Context.unify(promiseType, _) => true:
				macro @:pos(Context.currentPos()) $promiseArr._add(Promise.lazy(() -> return $funcCall));
			case Context.unify(futureType, _) => true:
				macro @:pos(Context.currentPos()) $promiseArr._add
					(Util.FutureArray.megaLazy(() -> return $funcCall));
			case x:
				Context.error("Can't unify", Context.currentPos());
				macro null;
		}
	}
}
