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
  $c->stash(roles_rs => $c->model('AuthDB::Role'));
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

      return;
    }

    return $c->res->redirect( $c->uri_for( $c->controller('AuthUsers')->action_for('profile'), [ $newuser->id ] ) );
  }
}

=head2 user

=cut

sub user : Chained('base'): PathPart(''): CaptureArgs(1) {
  my ($self, $c, $userid) = @_;
  if($userid =~ /\D/){
    die "Misuse of URL, userid does not contain only digit!"
  }
  my $user = $c->stash->{users_rs}->find({id => $userid}, {key => 'primary'});

  die "No such user" if(!$user);

  $c->stash(user => $user);
}

=head2 profile

=cut

sub profile : Chained('user') :PathPart('profile'): Args(0) {
  my ($self, $c) = @_;

}

=head2 edit

=cut

sub edit : Chained('user') :PathPart('edit') :Args(0) {
  my ($self, $c) = @_;

  if(lc $c->req->method eq 'post') {
    my $params = $c->req->params;
    my $user = $c->stash->{user};

    $user->update({
      email => $params->{email},
      password => $params->{password},
    });

    return $c->res->redirect( $c->uri_for(
      $c->controller('AuthUsers')->action_for('profile'),
      [$user->id]
    ));
  }
}

=head2 set_roles

=cut

sub set_roles :Chained('user') :PathPart('set_roles') :Args() {
  my ($self, $c) = @_;

  my $user = $c->stash->{user};
  if(lc $c->req->method eq 'post') {
    my @roles = $c->req->param('role');
    $user->set_all_roles(@roles);
  }
  $c->res->redirect($c->uri_for($c->controller()->action_for('profile'), [ $user->id ]));
}

=head1 AUTHOR

chakkrit,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
