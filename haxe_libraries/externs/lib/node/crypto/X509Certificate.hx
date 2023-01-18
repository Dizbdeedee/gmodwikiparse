package node.crypto;

/**
	Encapsulates an X509 certificate and provides read-only access to
	its information.
	
	```js
	const { X509Certificate } = await import('crypto');
	
	const x509 = new X509Certificate('{... pem encoded cert ...}');
	
	console.log(x509.subject);
	```
**/
@:jsRequire("crypto", "X509Certificate") extern class X509Certificate {
	function new(buffer:BinaryLike);
	/**
		Will be \`true\` if this is a Certificate Authority (CA) certificate.
	**/
	final ca : Bool;
	/**
		The SHA-1 fingerprint of this certificate.
		
		Because SHA-1 is cryptographically broken and because the security of SHA-1 is
		significantly worse than that of algorithms that are commonly used to sign
		certificates, consider using `x509.fingerprint256` instead.
	**/
	final fingerprint : String;
	/**
		The SHA-256 fingerprint of this certificate.
	**/
	final fingerprint256 : String;
	/**
		The SHA-512 fingerprint of this certificate.
	**/
	final fingerprint512 : String;
	/**
		The complete subject of this certificate.
	**/
	final subject : String;
	/**
		The subject alternative name specified for this certificate or `undefined`
		if not available.
	**/
	final subjectAltName : Null<String>;
	/**
		The information access content of this certificate or `undefined` if not
		available.
	**/
	final infoAccess : Null<String>;
	/**
		An array detailing the key usages for this certificate.
	**/
	final keyUsage : Array<String>;
	/**
		The issuer identification included in this certificate.
	**/
	final issuer : String;
	/**
		The issuer certificate or `undefined` if the issuer certificate is not
		available.
	**/
	@:optional
	final issuerCertificate : X509Certificate;
	/**
		The public key `KeyObject` for this certificate.
	**/
	final publicKey : KeyObject;
	/**
		A `Buffer` containing the DER encoding of this certificate.
	**/
	final raw : node.buffer.Buffer;
	/**
		The serial number of this certificate.
		
		Serial numbers are assigned by certificate authorities and do not uniquely
		identify certificates. Consider using `x509.fingerprint256` as a unique
		identifier instead.
	**/
	final serialNumber : String;
	/**
		The date/time from which this certificate is considered valid.
	**/
	final validFrom : String;
	/**
		The date/time until which this certificate is considered valid.
	**/
	final validTo : String;
	/**
		Checks whether the certificate matches the given email address.
		
		If the `'subject'` option is undefined or set to `'default'`, the certificate
		subject is only considered if the subject alternative name extension either does
		not exist or does not contain any email addresses.
		
		If the `'subject'` option is set to `'always'` and if the subject alternative
		name extension either does not exist or does not contain a matching email
		address, the certificate subject is considered.
		
		If the `'subject'` option is set to `'never'`, the certificate subject is never
		considered, even if the certificate contains no subject alternative names.
	**/
	function checkEmail(email:String, ?options:{ var subject : String; }):Null<String>;
	/**
		Checks whether the certificate matches the given host name.
		
		If the certificate matches the given host name, the matching subject name is
		returned. The returned name might be an exact match (e.g., `foo.example.com`)
		or it might contain wildcards (e.g., `*.example.com`). Because host name
		comparisons are case-insensitive, the returned subject name might also differ
		from the given `name` in capitalization.
		
		If the `'subject'` option is undefined or set to `'default'`, the certificate
		subject is only considered if the subject alternative name extension either does
		not exist or does not contain any DNS names. This behavior is consistent with [RFC 2818](https://www.rfc-editor.org/rfc/rfc2818.txt) ("HTTP Over TLS").
		
		If the `'subject'` option is set to `'always'` and if the subject alternative
		name extension either does not exist or does not contain a matching DNS name,
		the certificate subject is considered.
		
		If the `'subject'` option is set to `'never'`, the certificate subject is never
		considered, even if the certificate contains no subject alternative names.
	**/
	function checkHost(name:String, ?options:X509CheckOptions):Null<String>;
	/**
		Checks whether the certificate matches the given IP address (IPv4 or IPv6).
		
		Only [RFC 5280](https://www.rfc-editor.org/rfc/rfc5280.txt) `iPAddress` subject alternative names are considered, and they
		must match the given `ip` address exactly. Other subject alternative names as
		well as the subject field of the certificate are ignored.
	**/
	function checkIP(ip:String):Null<String>;
	/**
		Checks whether this certificate was issued by the given `otherCert`.
	**/
	function checkIssued(otherCert:X509Certificate):Bool;
	/**
		Checks whether the public key for this certificate is consistent with
		the given private key.
	**/
	function checkPrivateKey(privateKey:KeyObject):Bool;
	/**
		There is no standard JSON encoding for X509 certificates. The`toJSON()` method returns a string containing the PEM encoded
		certificate.
	**/
	function toJSON():String;
	/**
		Returns information about this certificate using the legacy `certificate object` encoding.
	**/
	function toLegacyObject():node.tls.PeerCertificate;
	/**
		Returns the PEM-encoded certificate.
	**/
	function toString():String;
	/**
		Verifies that this certificate was signed by the given public key.
		Does not perform any other validation checks on the certificate.
	**/
	function verify(publicKey:KeyObject):Bool;
	static var prototype : X509Certificate;
}