self: super: {
  kdePackages = super.kdePackages.overrideScope (final: prev: {
    kwin = prev.kwin.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./kwin-per-screen-zoom.patch ];
    });
  });
}
