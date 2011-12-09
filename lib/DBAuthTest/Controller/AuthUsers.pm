package DBAuthTest::Controller::AuthUsers;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

DBAuthTest::Controller::AuthUsers - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 base

=cut

sub base : Chained('/'): PathPart('authusers'): CaptureArgs(0) {
  my ($self, $c) = @_;
  $c->stash(users_rs => $c->model('AuthDB::User'));
}

=head2 add

=cut

sub add : Chained('base'): PathPart('add'): Args(0) {
  my ($self, $c) = @_;

  if(lc $c->req->method eq 'post'){
    my $params = $c->req->params;

    my $users_rs = $c->stash->{users_rs};

    my $newuser = eval { $users_rs->create({
      username => $params->{username},
      email => $params->{email},
      password => $params->{password},
    }) };
    if($@) {
      $c->log->debug("User tried to sign up with an invalid email address, redoing.. ");
      $c->stash( errors => { email => 'invalid' }, err => $@);
      return $c->res->redirect( $c->uri_for( $c->controller('AuthUser')->action_for('profile'), [ $newuser->id ] ) );
    }
  }
}

=head1 AUTHOR

chakkrit,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
