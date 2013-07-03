#!/usr/bin/env perl

use Mojolicious::Lite;

use Encode qw(decode_utf8);
use File::stat;
use Path::Tiny;
use WebAxs::Path;
use WebAxs::MimeTypes;

use Mojo::JSON;
use constant true  => Mojo::JSON->true;
use constant false => Mojo::JSON->false;

use constant WEBAXS_VERSION => '3.0';
BEGIN{ Mojo::Exception->throw("Not a directory: $ENV{WEBAXS_SHARE}") if $ENV{WEBAXS_SHARE} && not -d $ENV{WEBAXS_SHARE} }
use constant SHARED_DIR     => path($ENV{WEBAXS_SHARE} || app->home->rel_dir('./share'))->absolute;


plugin 'RenderFile';
plugin 'Directory' => {root => app->home->rel_dir('public'), dir_index => [qw/index.html index.htm/]};

app->types->type(\%WebAxs::MimeTypes);

helper ls => sub{
    my $self = shift;
    my $path = $self->path(shift);
    if ( -d $path->realpath ) {
        opendir my $dir, $path->realpath  or Mojo::Exception->throw("Can't opendir " . $path->realpath);
        return [map{ $self->stat($path->cat(decode_utf8($_))) } readdir $dir];
    } else {
        return [$self->stat($path)];
    }
};

helper stat => sub{
    my $self = shift;
    my $path = $self->path(shift);
    my $st = stat($path->realpath)  or Mojo::Exception->throw("Can't stat " . $path->realpath);
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
    my $path = decode_utf8($self->stash('path'));
    $self->render(json => $self->ls($path));
};

any [qw(get post)] => '/rpc/search(*path)' => {path => '/'} => sub{
    shift->render(status => 404, text => 'Command not supported');
};

any [qw(get post)] => '/rpc/cat(*path)' => {path => '/'} => sub{
    my $self = shift;
    my $path = decode_utf8($self->stash('path'));
    $path = $self->path($path);
    $self->_send_file($path, format => $path->extension, content_disposition => 'inline');
};

any [qw(get post)] => '/rpc/download(*path)' => {path => '/'} => sub{
    my $self = shift;
    my $path = decode_utf8($self->stash('path'));
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

any [qw(get post)] => '/rpc/thumbnail(*path)' => {path => '/'} => sub{
    my $self = shift;
    my $path = decode_utf8($self->stash('path'));
    $path = $self->path($path);
    return $self->render(status => 404, text => 'Unsupported file type')  unless $path =~ /\.(?:jpg|jpeg|gif|png)$/i;
    my $size = uc($self->param('size') || 'M');
    $size = 'M'  unless $size =~ /^(?:S|M|L|LL|3L|4L)$/;
    if ( $size =~ /^(?:3L|4L)$/ ) {
        $self->_send_file($path, format => $path->extension, content_disposition => 'inline');
    } else {
        $self->render_static("thumbs/$size.png");
    }
};

foreach my $cmd ( qw/upload upload_via_flash mkdir rm mv cp dir_config purge share/ ) {
    post "/rpc/$cmd(*path)" => {path => '/'} => sub{
        shift->render(status => 403, text => 'Permission denied');
    };
}

app-start;
