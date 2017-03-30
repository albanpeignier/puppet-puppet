define puppet::augeas::lens($source) {
  file { "/usr/local/share/augeas/lenses/${name}.aug":
    source => $source
  }
}
