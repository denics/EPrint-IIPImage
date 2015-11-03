# TODO
# add iipimage to the list of thumbnail types generated for DataObj::Documents
$c->add_trigger( EP_TRIGGER_THUMBNAIL_TYPES, sub {
    my( %args ) = @_;

	my $dataobj = $params{dataobj};
	my $list = $params{list};

	return 0 unless $dataobj->isa( "EPrints::DataObj::Document" );

	push @$list, "iipimage";

	return 0;
}, priority => 100);