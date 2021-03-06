{ cabal, haskeline, mtl }:

cabal.mkDerivation (self: {
  pname = "haskeline-class";
  version = "0.6.2";
  sha256 = "0xgdq2xgw2ccyfzkj5n36s5n6km5l947d2iy4y1qms8kbc05zmfl";
  buildDepends = [ haskeline mtl ];
  meta = {
    homepage = "http://community.haskell.org/~aslatter/code/haskeline-class";
    description = "Class interface for working with Haskeline";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [
      self.stdenv.lib.maintainers.andres
      self.stdenv.lib.maintainers.simons
    ];
  };
})
