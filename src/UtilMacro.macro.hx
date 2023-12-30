package;

import haxe.macro.Expr.ExprOf;
import haxe.macro.Expr;
import haxe.macro.Context;

class FutureArray_Use {
	public static macro function add(futureArr:ExprOf<Util.FutureArray>, funcCall:Expr) {
		return macro $futureArr._add(Util.FutureArray.megaLazy(() -> $funcCall));
	}
}

class PromiseArray_Use {
	public static macro function add(promiseArr:ExprOf<Util.PromiseArray>, funcCall:Expr) {
		var typ = Context.typeof(funcCall);
		var promiseType = Context.getType("tink.core.Promise");
		var futureType = Context.getType("tink.core.Future");
		return switch (typ) {
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
