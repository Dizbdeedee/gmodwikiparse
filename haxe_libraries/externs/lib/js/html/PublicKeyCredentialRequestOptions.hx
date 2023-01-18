package js.html;

typedef PublicKeyCredentialRequestOptions = {
	@:optional
	var allowCredentials : Array<PublicKeyCredentialDescriptor>;
	var challenge : node.crypto.webcrypto.BufferSource;
	@:optional
	var extensions : AuthenticationExtensionsClientInputs;
	@:optional
	var rpId : String;
	@:optional
	var timeout : Float;
	@:optional
	var userVerification : UserVerificationRequirement;
};