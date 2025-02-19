{ lib
, stdenv
, musl
, glibc
, upx
, enableStatic ? false
, ...
}:

stdenv.mkDerivation {
  pname = "pidproxy";
  version = "0.0.1";
  src = lib.cleanSource ./.;

  nativeBuildInputs = lib.optional enableStatic upx;
  buildInputs = [ (if enableStatic then musl else glibc) ];

  patchPhase = ''
    patchShebangs ./test
  '' + lib.optionalString (!enableStatic) ''
    sed -i 's/-static //g' Makefile
  '';

  preBuild = lib.optionalString enableStatic ''
    makeFlagsArray+=("CC=${stdenv.cc.targetPrefix}cc -isystem ${musl.dev}/include -B${musl}/lib -L${musl}/lib")
  '';

  postBuild = lib.optionalString enableStatic ''
    make pidproxy.upx
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./pidproxy${lib.optionalString enableStatic ".upx"} $out/bin/pidproxy
  '';

  doCheck = true;

  meta = with lib; {
    homepage = "https://github.com/ZentriaMC/pidproxy";
    description = "Lightweight signal forwarder for daemonizing programs";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
