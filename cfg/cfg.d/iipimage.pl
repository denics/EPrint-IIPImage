# Bazaar Configuration (do we need them?)

$c->{plugins}{"Convert::Thumbnails::IIPImage"}{params}{disable} = 0;
$c->{plugins}{"Screen::Admin::IIPImage"}{params}{disable} = 0;
$c->{plugins}{"Screen::EPMC::IIPImage"}{params}{disable} = 0;

# Stores the id of the Coversheet Dataobj that was used to generated the CS'ed document (do we need this?)
push @{$c->{fields}->{document}},{
    name => 'iipimageid',
    type => 'int',
};

# Configurations
$c->{iipimage}->{tile_geom} = "256x256";
$c->{iipimage}->{file_type} = "tif";

# thumbnail size, this value is dummy
$c->{plugins}->{"Convert::Thumbnails::IIPImage"}->{params}->{sizes} = {
	iipimage => [999,999], # dummy
};

# thumbnail conversion method, based on imagemagick convert
$c->{plugins}->{"Convert::Thumbnails::IIPImage"}->{params}->{call_convert} = sub {
	my( $plugin, $dir, $doc, $src, $geom, $size ) = @_;

	my $convert = $plugin->{'convert'};

	if (!defined($geom)) {
		EPrints::abort("NO GEOM");
	}

	my $fn = $size . "." . $c->{iipimage}->{file_type};
	my $dst = "$dir/$fn";

	my $tile_geom = $c->{iipimage}->{tile_geom};

	if ($c->{iipimage}->{tile_geom} == "tif") {
        $plugin->_system($convert,  "$src", "-define", "tiff:tile-geometry=$tile_geom", "-compress", "jpeg", "-quality", "90%", "ptif:$dst");
        $plugin->{_mime_type} = "image/tiff";
    }

	if( -s $dst ){
		return ($fn);
	}

	return ();
};

{

package EPrints::Script::Compiled;

sub run_iipimage_thumbnail_url{
	my( $self, $state, $doc ) = @_;

	if( ! $doc->[0]->isa( "EPrints::DataObj::Document" ) )
	{
		$self->runtime_error( "iipimage_thumbnail_url() must be called on a document object." );
	}
	my $repo = $state->{repository};

	my $url = $doc->[0]->thumbnail_url( "iipimage" );
	return [ undef, "STRING" ] unless defined $url;

	my $relation = "isiipimageThumbnailVersionOf";
	my $thumbnail = $doc->[0]->search_related( $relation )->item(0);
    
    # This is a temporary hack. we should find something more elegant...
    $url = substr($thumbnail->local_path, 43) . "/iipimage.tif";
    
	#$url .= sprintf( "?FIF=%s/%s", $thumbnail->local_path, URI::Escape::uri_escape_utf8( $thumbnail->value( "main" ), "^A-Za-z0-9\-\._~\/" ) );

	return [ $url, "STRING" ];
}

}