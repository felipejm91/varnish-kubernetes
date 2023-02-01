vcl 4.1;
import std;

backend teste {
	.host = "192.168.0.4";
    .port = "9000";
}

sub vcl_recv {

	if (req.http.host == "testevarnish.com.br") {
		set req.backend_hint = teste;
	}


	if (req.restarts == 0) {
          if (req.http.X-Forwarded-For) {
		set req.http.X-Forwarded-For = req.http.x-real-ip;
          } else {
		set req.http.X-Forwarded-For = req.http.x-real-ip;
	  }
	}

	if (req.http.Authorization || req.method == "POST") {
		return (pass);
	}

	if (req.url ~ "/feed") {
		return (pass);
	}

	if (req.http.User-Agent ~ "(Mobile|Android|iPhone|iPad|SymbianOS|^BlackBerry)") {
		#return (pass);
		set req.http.X-Device = "smart";
	}

	#EXCLUSÃO DE TERMOS NA URL DO SITE
	if (req.url ~ "/(u-admin|post\.php|edit\.php|wp-admin|wp-login|carrinho|cart|orcamento|checkout|minha-conta|my-account|\?add-to-cart=|add-to-cart|interior|search|wp-content|wp-includes|wp-json|wc-api/*|addons|logout|lost-password)") {
	    return (pass);
	}

	 # Exclude wp-cron or when the front end is being
	 # previewed from the administrator/developer
	 if (req.url ~ "/wp-cron.php" || req.url ~ "preview=true") {
	     return (pass);
	 }

	# Exclude everything that is neither GET nor HEAD
	if (req.method != "GET" && req.method != "HEAD") {
	     return (pass);
	}

	# Exclude caching Ajax requests
	if (req.http.X-Requested-With == "XMLHttpRequest") {
	     return(pass);
	}

	if (req.url ~ "added_item=" ) {
		return (pass);
	}

	if (req.url ~ "orcamento/added_item" ) {
		return (pass);
	}

	if (req.url ~ "updated_item" ) {
		return (pass);
	}

	# Pass through the WooCommerce API
	if (req.url ~ "\?wc-api=" ) {
		return (pass);
	}

	if (req.url ~ "\?wc-ajax=" ) {
		return (pass);
	}

	if (req.http.cookie ~ "woocommerce_cart_hash" || req.http.cookie ~ "woocommerce_items_in_cart" ||  req.http.cookie ~ "wordpress_logged_in" ||  req.http.cookie ~ "resetpass" ){
		return (pass);
	}

	if (req.url ~ "^/text.php$") {
		return (pass);
	}

	if (req.url ~ "^/xmlrpc.php$") {
		return (pass);
	}

	if (req.url ~ "^/installer.php$") {
		return (pass);
	}

	unset req.http.cookie;

}

sub vcl_hash {
	if (req.http.X-Device ~ "smart" ) {
		hash_data(req.http.X-Device);
	}
}

sub vcl_backend_response {

	#EXCLUSÃO DE TERMOS NA URL DO SITE
	if ((bereq.url !~ "/(add-to-cart|\?add-to-cart=|post\.php|edit\.php|u-admin|wp-admin|wp-login|carrinho|orcamento|checkout|minha-conta|my-account|interior|search|wp-content|wp-includes|wp-json|wc-api/*|addons|logout|lost-password)") && (bereq.http.cookie !~ "woocommerce_cart_hash" || bereq.http.cookie !~ "woocommerce_items_in_cart" ||  bereq.http.cookie !~ "wordpress_logged_in" ||  bereq.http.cookie !~ "resetpass") && (beresp.status != 302))
	{
		unset beresp.http.set-cookie;
		set beresp.ttl = 1h;
		set beresp.grace = 2h;
	}

	if (bereq.url ~ "^/text.php$") {
		unset beresp.http.set-cookie;
	}

	if (bereq.url ~ "^/xmlrpc.php$") {
		unset beresp.http.set-cookie;
	}
}

sub vcl_deliver {
	unset resp.http.Link;
	unset resp.http.Via;
	unset resp.http.X-Varnish;
	unset resp.http.Age;

	if (obj.hits > 0) {
	        set resp.http.X-Cache = "HIT";
	}else{
	        set resp.http.X-Cache = "MISS";
	}
}
