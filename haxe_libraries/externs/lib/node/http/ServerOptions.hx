package node.http;

typedef ServerOptions<Request, Response> = {
	@:optional
	var IncomingMessage : Request;
	@:optional
	var ServerResponse : Response;
	/**
		Optionally overrides the value of
		`--max-http-header-size` for requests received by this server, i.e.
		the maximum length of request headers in bytes.
	**/
	@:optional
	var maxHeaderSize : Float;
	/**
		Use an insecure HTTP parser that accepts invalid HTTP headers when true.
		Using the insecure parser should be avoided.
		See --insecure-http-parser for more information.
	**/
	@:optional
	var insecureHTTPParser : Bool;
	/**
		If set to `true`, it disables the use of Nagle's algorithm immediately after a new incoming connection is received.
	**/
	@:optional
	var noDelay : Bool;
	/**
		If set to `true`, it enables keep-alive functionality on the socket immediately after a new incoming connection is received,
		similarly on what is done in `socket.setKeepAlive([enable][, initialDelay])`.
	**/
	@:optional
	var keepAlive : Bool;
	/**
		If set to a positive number, it sets the initial delay before the first keepalive probe is sent on an idle socket.
	**/
	@:optional
	var keepAliveInitialDelay : Float;
};