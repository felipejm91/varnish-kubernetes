# specify the VCL syntax version to use
vcl 4.1;

# import vmod_dynamic for better backend name resolution
import std;

# we won't use any static backend, but Varnish still need a default one
backend teste {
	.host = "192.168.0.2";
    .port = "8082";
}

sub vcl_recv {
	if (req.http.host == "www.teste.com.br") {
		set req.backend_hint = teste;
	}
}