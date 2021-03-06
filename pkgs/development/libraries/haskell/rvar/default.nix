{ cabal, MonadPrompt, mtl, randomSource, transformers }:

cabal.mkDerivation (self: {
  pname = "rvar";
  version = "0.2.0.1";
  sha256 = "17wgd4gc1hn04dck168nkyzn9jyipgbysxsznyzy2z36vafqqqbm";
  buildDepends = [ MonadPrompt mtl randomSource transformers ];
  meta = {
    homepage = "https://github.com/mokus0/random-fu";
    description = "Random Variables";
    license = self.stdenv.lib.licenses.publicDomain;
    platforms = self.ghc.meta.platforms;
    maintainers = [
      self.stdenv.lib.maintainers.andres
      self.stdenv.lib.maintainers.simons
    ];
  };
})
