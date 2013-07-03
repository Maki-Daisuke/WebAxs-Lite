#!/usr/bin/env perl

use Carp;
use Encode qw(decode_utf8);
use File::stat;
use Path::Tiny;
use URI::Escape::XS qw(uri_unescape);
use WebAxs::Path;
use WebAxs::MimeTypes;

use Mojo::JSON;
use constant true  => Mojo::JSON->true;
use constant false => Mojo::JSON->false;

use constant WEBAXS_VERSION => '3.0';
use constant SHARED_DIR     => path(shift)->absolute;


sub _decode_uri ($) {
    decode_utf8(uri_unescape($_[0]));
}


use Mojolicious::Lite;

plugin 'RenderFile';

app->types->type(\%WebAxs::MimeTypes);

helper ls => sub{
    my $self = shift;
    my $path = $self->path(shift);
    if ( -d $path->realpath ) {
        opendir my $dir, $path->realpath  or croak "Can't opendir " . $path->realpath;
        return [map{ $self->stat($path->cat($_)) } readdir $dir];
    } else {
        return [$self->stat($path)];
    }
};

helper stat => sub{
    my $self = shift;
    my $path = $self->path(shift);
    my $st = stat($path->realpath)  or croak "Can't stat " . $path->realpath;
    return {
        name      => $path->basename,
        path      => $path->clean,
        directory => -d _,
        writable  => false,
        size      => $st->size,
        atime     => $st->atime,
        mtime     => $st->mtime,
        ctime     => $st->ctime,
    };
};

helper path => sub{
    my ($self, $path) = @_;
    WebAxs::Path->new(SHARED_DIR, $path);
};


post '/rpc/login' => sub{
    my $self = shift;
    $self->render(status => 403, text => 'Illegal login name or password');
};

post '/rpc/logout' => sub{
    my $self = shift;
    $self->render(text => 'Bye.');
};

get '/rpc/user_config' => sub{
    my $self = shift;
    $self->render(json => {
            webaxs_version => WEBAXS_VERSION,
            name           => ':anonymous',
            lang           => "en",
            ext_config     => {}
    });
};

any [qw(get post)] => '/rpc/ls(*path)' => {path => '/'} => sub{
    my $self = shift;
    my $path = _decode_uri($self->stash('path'));
    $self->render(json => $self->ls($path));
};

any [qw(get post)] => '/rpc/search(*path)' => {path => '/'} => sub{
    shift->render(status => 404, text => 'Command not supported');
};

any [qw(get post)] => '/rpc/cat(*path)' => {path => '/'} => sub{
    my $self = shift;
    my $path = _decode_uri($self->stash('path'));
    $path = $self->path($path);
    $self->_send_file($path, format => $path->extension, content_disposition => 'inline');
};

any [qw(get post)] => '/rpc/download(*path)' => {path => '/'} => sub{
    my $self = shift;
    my $path = _decode_uri($self->stash('path'));
    $path = $self->path($path);
    $self->_send_file($path, content_disposition => 'attachment');
};

helper _send_file => sub{
    my $self = shift;
    my $path = shift;
    my %opts = @_;
    if ( -e $path->realpath ) {
        if ( -f $path->realpath ) {
            $self->render_file(filepath => $path->realpath, %opts);
            return $path;
        } else {
            $self->render(status => 403, text => 'Not a regular file');
        }
    } else {
        $self->render(status => 404, text => 'Not found');
    }
    return '';
};

any [qw(get post)] => '/rpc/download.zip(*path)' => {path => '/'} => sub{
    shift->render(status => 404, text => 'Command not supported');
};

post '/rpc/upload(*path)' => {path => '/'} => sub{
    shift->render(status => 403, text => 'Permission denied');
};

post '/rpc/upload_via_flash(*path)' => {path => '/'} => sub{
    shift->render(status => 403, text => 'Permission denied');
};

post '/rpc/mkdir(*path)' => {path => '/'} => sub{
    shift->render(status => 403, text => 'Permission denied');
};

post '/rpc/rm(*path)' => {path => '/'} => sub{
    shift->render(status => 403, text => 'Permission denied');
};

post '/rpc/mv(*path)' => {path => '/'} => sub{
    shift->render(status => 403, text => 'Permission denied');
};

post '/rpc/cp(*path)' => {path => '/'} => sub{
    shift->render(status => 403, text => 'Permission denied');
};

post '/rpc/thumbnail(*path)' => {path => '/'} => sub{
    shift->render(status => 404, text => 'Command not supported');
};

post '/rpc/dir_config(*path)' => {path => '/'} => sub{
    shift->render(status => 404, text => 'Command not supported');
};

any [qw(get post)] => '/rpc/purge(*path)' => {path => '/'} => sub{
    shift->render(status => 404, text => 'Command not supported');
};

any [qw(get post)] => '/rpc/share(*path)' => {path => '/'} => sub{
    shift->render(status => 404, text => 'Command not supported');
};

any [qw(get post)] => '/rpc/version' => sub{
    shift->render(status => 404, text => 'Command not supported');
};

app-start;