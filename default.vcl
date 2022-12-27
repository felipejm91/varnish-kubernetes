# specify the VCL syntax version to use
vcl 4.1;

# import vmod_dynamic for better backend name resolution
import std;

# we won't use any static backend, but Varnish still need a default one
backend backend_name {
	.host = "ip_backend_server";
    .port = "port_backend_server";
}

sub vcl_recv {
	if (req.http.host == "www.teste.com.br") {
		set req.backend_hint = backend_name;
	}
}
