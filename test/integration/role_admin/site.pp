class { '::ve_base': }

class { '::exim':
  postmaster => 'exim@syseleven.de',
  role       => 'admin',
}

