WebAxs-Lite - WebAxs for Minimalist
=============================================

## Description ##

Experimental implementation of WebAxs server with minimal, read-only feature set.

## Installation ##

Install [Carton](http://search.cpan.org/~miyagawa/carton-v0.9.15/lib/Carton.pm) with [cpanm](http://search.cpan.org/dist/App-cpanminus/bin/cpanm):

	> cpanm Carton

or, with `cpan`:

	> cpan Carton

Clone the repository:

	> git clone https://github.com/Maki-Daisuke/WebAxs-Lite.git

Install CPAN modules with `carton` command:

	> cd WebAxs-Lite
	> carton install

That's it!

## How to Use ##

WebAxs-Lite is implemented with Mojolicisou::Lite, and so, the easiest way to lanuch the server is using `morbo`:

	> carton exec -Ilib -- morbo webaxs_lite.pl
	[Wed Jul  3 18:26:05 2013] [info] Listening at "http://*:3000".
	Server available at http://127.0.0.1:3000.

Now you can call WebAxs-RPC via HTTP:

	> curl http://localhost:3000/rpc/ls/
	[{"ctime":1372737751,"mtime":1372737751,"writable":false,"name":".","atime":1372844252,"path":"\/","directory":1,"size":
	170},{"ctime":1372737751,"mtime":1372737751,"writable":false,"name":"..","atime":1372844252,"path":"\/","directory":1,"s
	ize":170},{"ctime":1372694967,"mtime":1372694967,"writable":false,"name":"hello.txt","atime":1372817415,"path":"\/hello.
	txt","directory":0,"size":14},{"ctime":1372737799,"mtime":1372737799,"writable":false,"name":"photo","atime":1372844247,
	"path":"\/photo","directory":1,"size":136}]

You can specifies directory to publish by WEBAXS_SHARE environment variable:

	> WEBAXS_SHARE=/home/your_account carton exec -Ilib -- morbo webaxs_lite.pl

The specified directory will be the root directory in WebAccess filesystem tree. By default, the server publishes `share`
directory in the distribution.

If you want to use WebAccess UI, copy the related HTML/JS/CSS files into `public` directory under the distribution like this:

	public/
	├── MultiDevice/
	├── badrequest.html
	├── badrequest_redirect.html
	├── base_config.json
	├── enable-javascript.png
	├── index.html
	├── st/
	├── thumbs/
	└── ui/

These UI files are not distributed with this software because of copyright and license.

## Term of Use

This software is distributed under [the revised BSD License](http://opensource.org/licenses/bsd-license.php).

Copyright (c) 2013, Daisuke (yet another) Maki All rights reserved.
