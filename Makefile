PATH:=$(PREFIX)/bin:$(PATH)

all: ocaml findlib num ocamlbuild camlp-streams camlp4 lablgtk z3 csexp dune sexplib0 base res stdio cppo ocplib-endian stdint result capnp capnp-ocaml stdlib-shims ocaml-compiler-libs ppx_derivers ppxlib ppx_parser

# ---- OCaml ----

OCAML_VERSION=4.14.0
OCAML_BINARY=$(PREFIX)/bin/ocamlopt.opt

ocaml-$(OCAML_VERSION).tar.gz:
	./download ocaml-$(OCAML_VERSION).tar.gz https://github.com/ocaml/ocaml/archive/$(OCAML_VERSION).tar.gz 39f44260382f28d1054c5f9d8bf4753cb7ad64027da792f7938344544da155e8

ocaml-$(OCAML_VERSION): ocaml-$(OCAML_VERSION).tar.gz
	tar xzf ocaml-$(OCAML_VERSION).tar.gz

$(OCAML_BINARY): | ocaml-$(OCAML_VERSION)
	cd ocaml-$(OCAML_VERSION) && \
        ./configure -prefix $(PREFIX) && \
        make && \
        make install

ocaml: $(OCAML_BINARY)
.PHONY: ocaml

clean::
	-rm -Rf ocaml-$(OCAML_VERSION)

# ---- Findlib ----

FINDLIB_VERSION=1.9.5
FINDLIB_BINARY=$(PREFIX)/bin/ocamlfind

findlib-$(FINDLIB_VERSION).tar.gz:
	./download findlib-$(FINDLIB_VERSION).tar.gz http://download.camlcity.org/download/findlib-$(FINDLIB_VERSION).tar.gz 0d4704e60caf313c1bb4565d8690d503ce51fb93c2ea50e22b2e9812243a2571

findlib-$(FINDLIB_VERSION): findlib-$(FINDLIB_VERSION).tar.gz
	tar xzf findlib-$(FINDLIB_VERSION).tar.gz

findlib-$(FINDLIB_VERSION)/Makefile.config: $(OCAML_BINARY) | findlib-$(FINDLIB_VERSION)
	cd findlib-$(FINDLIB_VERSION) && \
	./configure \
	  -bindir $(PREFIX)/bin \
          -mandir $(PREFIX)/man \
          -sitelib $(PREFIX)/lib/ocaml \
          -config $(PREFIX)/etc/findlib.conf

$(FINDLIB_BINARY): findlib-$(FINDLIB_VERSION)/Makefile.config
	cd findlib-$(FINDLIB_VERSION) && \
        make all && \
        make opt && \
        make install

findlib: $(FINDLIB_BINARY)
.PHONY: findlib

clean::
	-rm -Rf findlib-$(FINDLIB_VERSION)

# ---- Num ----

NUM_VERSION=1.4
NUM_BINARY=$(PREFIX)/lib/ocaml/nums.cmxa

num-$(NUM_VERSION).tar.gz:
	./download num-$(NUM_VERSION).tar.gz https://github.com/ocaml/num/archive/v$(NUM_VERSION).tar.gz 015088b68e717b04c07997920e33c53219711dfaf36d1196d02313f48ea00f24

num-$(NUM_VERSION): num-$(NUM_VERSION).tar.gz
	tar xzf num-$(NUM_VERSION).tar.gz

$(NUM_BINARY): $(FINDLIB_BINARY) | num-$(NUM_VERSION)
	cd num-$(NUM_VERSION) && make all && make install

num: $(NUM_BINARY)
.PHONY: num

clean::
	-rm -Rf num-$(NUM_VERSION)

# ---- ocamlbuild ----

OCAMLBUILD_VERSION=0.14.2
OCAMLBUILD_BINARY=$(PREFIX)/bin/ocamlbuild

ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz:
	./download ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz https://github.com/ocaml/ocamlbuild/archive/$(OCAMLBUILD_VERSION).tar.gz 62d2dab6037794c702a83ac584a7066d018cf1645370d1f3d5764c2b458791b1

ocamlbuild-$(OCAMLBUILD_VERSION): ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz
	tar xzf ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz

$(OCAMLBUILD_BINARY): $(FINDLIB_BINARY) | ocamlbuild-$(OCAMLBUILD_VERSION)
	cd ocamlbuild-$(OCAMLBUILD_VERSION) && \
        make configure && make && make install

ocamlbuild: $(OCAMLBUILD_BINARY)
.PHONY: ocamlbuild

clean::
	-rm -Rf ocamlbuild-$(OCAMLBUILD_VERSION)

# ---- dune ----
DUNE_VERSION=3.7.1
DUNE_BINARY=$(PREFIX)/bin/dune

dune-$(DUNE_VERSION).tar.gz:
	./download $@ https://github.com/ocaml/dune/archive/refs/tags/$(DUNE_VERSION).tar.gz 9ddc1dae09e7be6d0bf22b7d1584d95a1b3d4f5d1bae1d4095dc4e1833fa86b2

dune-$(DUNE_VERSION): dune-$(DUNE_VERSION).tar.gz
	tar xzf $<

$(DUNE_BINARY): $(OCAML_BINARY) $(FINDLIB_BINARY) | dune-$(DUNE_VERSION)
	cd $| && ./configure --libdir=$(PREFIX)/lib/ocaml && make release && make install

dune: $(DUNE_BINARY)
.PHONY: dune

clean::
	-rm -Rf dune-$(DUNE_VERSION)

DUNE_INSTALL=dune build @install --profile release && dune install --profile release --prefix=$(PREFIX) --libdir=$(PREFIX)/lib/ocaml

# ---- camlp-streams ----
CAMLP_STREAMS_VERSION=5.0.1
CAMLP_STREAMS_BINARY=$(PREFIX)/lib/ocaml/camlp-stream/camlp-streams.cmxa

camlp-streams-$(CAMLP_STREAMS_VERSION).tar.gz:
	./download $@ https://github.com/ocaml/camlp-streams/archive/refs/tags/v$(CAMLP_STREAMS_VERSION).tar.gz ad71f62406e9bb4e7fb5d4593ede2af6c68f8b0d96f25574446e142c3eb0d9a4

camlp-streams-$(CAMLP_STREAMS_VERSION): camlp-streams-$(CAMLP_STREAMS_VERSION).tar.gz
	tar xzf $<

$(CAMLP_STREAMS_BINARY): $(DUNE_BINARY) | camlp-streams-$(CAMLP_STREAMS_VERSION)
	cd $| && $(DUNE_INSTALL)

camlp-streams: $(CAMLP_STREAMS_BINARY)
.PHONY: camlp-streams

clean::
	-rm -Rf camlp-streams-$(CAMLP_STREAMS_VERSION)

# ---- camlp4 ----

CAMLP4_VERSION:=4.14+1
CAMLP4_DIR:=camlp4-$(subst +,-,$(CAMLP4_VERSION))
CAMLP4_BINARY:=$(PREFIX)/bin/camlp4o

$(CAMLP4_DIR).tar.gz:
	./download $(CAMLP4_DIR).tar.gz https://github.com/ocaml/camlp4/archive/$(CAMLP4_VERSION).tar.gz 553b6805dffc05eb4749b0293df47a18b82b9d9dcc125d688e55f13cbec0b93a

$(CAMLP4_DIR): $(CAMLP4_DIR).tar.gz
	tar xzf $(CAMLP4_DIR).tar.gz

$(CAMLP4_BINARY): $(OCAMLBUILD_BINARY) $(CAMLP_STREAMS_BINARY) $(CAMLP_STREAMS_BINARY) | $(CAMLP4_DIR)
	cd $(CAMLP4_DIR) && \
        ./configure && make all && make install

camlp4: $(CAMLP4_BINARY)
.PHONY: camlp4

clean::
	-rm -Rf $(CAMLP4_DIR)

# ---- lablgtk ----

LABLGTK_VERSION=2.18.13
LABLGTK_BINARY=$(PREFIX)/lib/ocaml/lablgtk2/lablgtk.cmxa

lablgtk-$(LABLGTK_VERSION).tar.gz:
	./download lablgtk-$(LABLGTK_VERSION).tar.gz https://github.com/garrigue/lablgtk/archive/refs/tags/$(LABLGTK_VERSION).tar.gz 7b9e680452458fd351cf8622230d62c3078db528446384268cd0dc37be82143c

lablgtk-$(LABLGTK_VERSION): lablgtk-$(LABLGTK_VERSION).tar.gz
	tar xzf lablgtk-$(LABLGTK_VERSION).tar.gz

$(LABLGTK_BINARY): $(FINDLIB_BINARY) | lablgtk-$(LABLGTK_VERSION)
	cd lablgtk-$(LABLGTK_VERSION) && \
        ./configure --prefix=$(PREFIX) && make world && make install

lablgtk: $(LABLGTK_BINARY)
.PHONY: lablgtk

clean::
	-rm -Rf lablgtk-$(LABLGTK_VERSION)

# ---- Z3 ----

Z3_VERSION=4.8.5
Z3_BINARY=$(PREFIX)/bin/z3
Z3_DIR=z3-Z3-$(Z3_VERSION)

z3-$(Z3_VERSION).tar.gz:
	./download z3-$(Z3_VERSION).tar.gz https://github.com/Z3Prover/z3/archive/Z3-$(Z3_VERSION).tar.gz 4e8e232887ddfa643adb6a30dcd3743cb2fa6591735fbd302b49f7028cdc0363

$(Z3_DIR): z3-$(Z3_VERSION).tar.gz
	tar xzf z3-$(Z3_VERSION).tar.gz

$(Z3_BINARY): $(FINDLIB_BINARY) $(NUM_BINARY) | $(Z3_DIR)
	cd $(Z3_DIR) && \
        python3 scripts/mk_make.py --ml --prefix=$(PREFIX) && \
        cd build && make && make install

z3: $(Z3_BINARY)
.PHONY: z3

clean::
	-rm -Rf $(Z3_DIR)

# ---- csexp ----
CSEXP_VERSION=1.5.1
CSEXP_BINARY=$(PREFIX)/lib/ocaml/csexp/csexp.cmxa

csexp-$(CSEXP_VERSION).tar.gz:
	./download $@ https://github.com/ocaml-dune/csexp/archive/refs/tags/$(CSEXP_VERSION).tar.gz ffab41b0b0f65ade305043205229a7649591195cbe86e24f2c254e9dc5b14a34

csexp-$(CSEXP_VERSION): csexp-$(CSEXP_VERSION).tar.gz
	tar xzf $<

$(CSEXP_BINARY): $(DUNE_BINARY) | csexp-$(CSEXP_VERSION)
	cd $| && $(DUNE_INSTALL)

csexp: $(CSEXP_BINARY)
.PHONY: csexp

# ---- other dune libraries ----
STDUNE_BINARY=$(PREFIX)/lib/ocaml/stdune/stdune.cmxa
$(STDUNE_BINARY): $(DUNE_BINARY) $(CSEXP_BINARY) | dune-$(DUNE_VERSION)
	cd $| && dune build stdune.install && dune install stdune --prefix=$(PREFIX) --libdir=$(PREFIX)/lib/ocaml

DUNE_CONF_BINARY=$(PREFIX)/lib/ocaml/dune-configurator/configurator.cmxa
$(DUNE_CONF_BINARY): $(DUNE_BINARY) $(STDUNE_BINARY) | dune-$(DUNE_VERSION)
	cd $| && dune build dune-configurator.install && dune install dune-configurator --prefix=$(PREFIX) --libdir=$(PREFIX)/lib/ocaml

# ---- sexplib0 ----
SEXPLIB0_VERSION=0.15.1
SEXPLIB0_BINARY=$(PREFIX)/lib/ocaml/sexplib0/sexplib0.cmxa

sexplib0-$(SEXPLIB0_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/sexplib0/archive/refs/tags/v$(SEXPLIB0_VERSION).tar.gz e8cd817eb3bc3f84a2065fa0255ab2b986a24baf1cc329d05627c516464267b3

sexplib0-$(SEXPLIB0_VERSION): sexplib0-$(SEXPLIB0_VERSION).tar.gz
	tar xzf $<

$(SEXPLIB0_BINARY): $(DUNE_BINARY) | sexplib0-$(SEXPLIB0_VERSION)
	cd $| && $(DUNE_INSTALL)

sexplib0: $(SEXPLIB0_BINARY)
.PHONY: sexplib0

clean::
	-rm -Rf sexplib0-$(SEXPLIB0_VERSION)

# ---- base ----
BASE_VERSION=0.15.1
BASE_BINARY=$(PREFIX)/lib/ocaml/base/base.cmxa

base-$(BASE_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/base/archive/refs/tags/v$(BASE_VERSION).tar.gz 755e303171ea267e3ba5af7aa8ea27537f3394d97c77d340b10f806d6ef61a14

base-$(BASE_VERSION): base-$(BASE_VERSION).tar.gz
	tar xzf $<

$(BASE_BINARY): $(DUNE_BINARY) $(DUNE_CONF_BINARY) $(STDUNE_BINARY) $(SEXPLIB0_BINARY) | base-$(BASE_VERSION)
	cd $| && $(DUNE_INSTALL)

base: $(SEXPLIB0_BINARY) $(BASE_BINARY)
.PHONY: base

clean::
	-rm -Rf base-$(BASE_VERSION)

# ---- res ----
RES_VERSION=5.0.1
RES_BINARY=$(PREFIX)/lib/ocaml/res/res.cmxa

res-$(RES_VERSION).tar.gz:
	./download $@ https://github.com/mmottl/res/archive/refs/tags/$(RES_VERSION).tar.gz df7965f5021a4422a462545647aad420a50dd8ba69c504eff74b3c346593b70d

res-$(RES_VERSION): res-$(RES_VERSION).tar.gz
	tar xzf $<

$(RES_BINARY): $(DUNE_BINARY) | res-$(RES_VERSION)
	cd $| && $(DUNE_INSTALL)

res: $(RES_BINARY)
.PHONY: res

clean::
	-rm -Rf res-$(RES_VERSION)

# ---- stdio ----
STDIO_VERSION=0.15.0
STDIO_BINARY=$(PREFIX)/lib/ocaml/stdio/stdio.cmxa

stdio-$(STDIO_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/stdio/archive/refs/tags/v$(STDIO_VERSION).tar.gz 49f2478fc08677a54bffaeb2b017d23ece19ab5c1d6c993513a20b34aeee81a7

stdio-$(STDIO_VERSION): stdio-$(STDIO_VERSION).tar.gz
	tar xzf $<

$(STDIO_BINARY): $(DUNE_BINARY) $(BASE_BINARY) | stdio-$(STDIO_VERSION)
	cd $| && $(DUNE_INSTALL)

stdio: $(STDIO_BINARY)
.PHONY: stdio

clean::
	-rm -Rf stdio-$(STDIO_VERSION)

# ---- cppo ----
CPPO_VERSION=1.6.9
CPPO_BINARY=$(PREFIX)/bin/cppo

cppo-$(CPPO_VERSION).tar.gz:
	./download $@ https://github.com/ocaml-community/cppo/archive/refs/tags/v$(CPPO_VERSION).tar.gz 16036d85c11d330a7c8b56f4e071d6bbe86d8937c89d3d79f6eef0e38bdda26a

cppo-$(CPPO_VERSION): cppo-$(CPPO_VERSION).tar.gz
	tar xzf $<

$(CPPO_BINARY): $(DUNE_BINARY) $(OCAMLBUILD_BINARY) | cppo-$(CPPO_VERSION)
	cd $| && $(DUNE_INSTALL)

cppo: $(CPPO_BINARY)
.PHONY: cppo

clean::
	-rm -Rf cppo-$(CPPO_VERSION)

# ---- ocplib-endian ----
OCPLIB-ENDIAN_VERSION=1.2
OCPLIB-ENDIAN_BINARY=$(PREFIX)/lib/ocaml/ocplib-endian/ocplib_endian.cmxa

ocplib-endian-$(OCPLIB-ENDIAN_VERSION).tar.gz:
	./download $@ https://github.com/OCamlPro/ocplib-endian/archive/$(OCPLIB-ENDIAN_VERSION).tar.gz 97ae74e8aeead46a0475df14af637ce78e2372c07258619ad8967506f2d4b320

ocplib-endian-$(OCPLIB-ENDIAN_VERSION): ocplib-endian-$(OCPLIB-ENDIAN_VERSION).tar.gz
	tar xzf $<

$(OCPLIB-ENDIAN_BINARY): $(DUNE_BINARY) $(CPPO_BINARY) | ocplib-endian-$(OCPLIB-ENDIAN_VERSION)
	cd $| && $(DUNE_INSTALL)

ocplib-endian: $(OCPLIB-ENDIAN_BINARY)
.PHONY: ocplib-endian

clean::
	-rm -Rf ocplib-endian-$(OCPLIB-ENDIAN_VERSION)

# ---- stdint ----
STDINT_VERSION=0.7.2
STDINT_DIR=ocaml-stdint-$(STDINT_VERSION)
STDINT_BINARY=$(PREFIX)/lib/ocaml/stdint/stdint.cmxa

stdint-$(STDINT_VERSION).tar.gz:
	./download $@ https://github.com/andrenth/ocaml-stdint/archive/refs/tags/$(STDINT_VERSION).tar.gz b0efc17f83f4a744f0a578edce476eba83aa1894c7e45993db375189b47c5e64

$(STDINT_DIR): stdint-$(STDINT_VERSION).tar.gz
	tar xzf $<

$(STDINT_BINARY): $(DUNE_BINARY) | $(STDINT_DIR)
	cd $| && $(DUNE_INSTALL)

stdint: $(STDINT_BINARY)
.PHONY: stdint

clean::
	-rm -Rf stdint-$(STDINT_VERSION)

# ---- result ----
RESULT_VERSION=1.5
RESULT_BINARY=$(PREFIX)/lib/ocaml/result/result.cmxa

result-$(RESULT_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/result/archive/refs/tags/$(RESULT_VERSION).tar.gz 1072a8b0b35bd6df939c0670add33027f981e4f69a53233cb006b442fa12af30

result-$(RESULT_VERSION): result-$(RESULT_VERSION).tar.gz
	tar xzf $<

$(RESULT_BINARY): $(DUNE_BINARY) | result-$(RESULT_VERSION)
	cd $| && $(DUNE_INSTALL)

result: $(RESULT_BINARY)
.PHONY: result

clean::
	-rm -Rf result-$(RESULT_VERSION)

# ---- cap'n proto ----
## capnp tool to produce stubs code based on .capnp schema files, also installs the C++ plugin to create C++ stubs
CAPNP_VERSION=0.10.4
CAPNP_DIR=capnproto-c++-$(CAPNP_VERSION)
CAPNP_BINARY=$(PREFIX)/bin/capnp

capnp-$(CAPNP_VERSION).tar.gz:
	./download $@ https://capnproto.org/capnproto-c++-$(CAPNP_VERSION).tar.gz 981e7ef6dbe3ac745907e55a78870fbb491c5d23abd4ebc04e20ec235af4458c

$(CAPNP_DIR): capnp-$(CAPNP_VERSION).tar.gz
	tar xzf $<
	patch -u $(CAPNP_DIR)/CMakeLists.txt -i capnpCMakeLists.patch
	patch -u $(CAPNP_DIR)/src/kj/CMakeLists.txt -i capnp_src_kjCMakeLists.patch

$(CAPNP_BINARY): | $(CAPNP_DIR)
	cd $| && cmake -G Ninja -S . -B build -DWITH_ZLIB=OFF -DWITH_OPENSSL=OFF -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && cmake --build build --target install

capnp: $(CAPNP_BINARY)
.PHONY: capnp

clean::
	-rm -Rf $(CAPNP_DIR)

## capnp plugin for ocaml, which allows to create stubs code with the capnp tool
CAPNP_OCAML_VERSION=3.5.0
CAPNP_OCAML_DIR=capnp-ocaml-$(CAPNP_OCAML_VERSION)
CAPNP_OCAML_BINARY=$(PREFIX)/lib/ocaml/capnp/capnp.cmxa

capnp-ocaml-$(CAPNP_OCAML_VERSION).tar.gz:
	./download $@ https://github.com/capnproto/capnp-ocaml/archive/refs/tags/v$(CAPNP_OCAML_VERSION).tar.gz 298332601b98e271d704799520ae066f0a00c8663014b8bcb94f739eb0fb2e9f

$(CAPNP_OCAML_DIR): capnp-ocaml-$(CAPNP_OCAML_VERSION).tar.gz
	tar xzf $<

$(CAPNP_OCAML_BINARY): $(DUNE_BINARY) $(RES_BINARY) $(STDIO_BINARY) $(OCPLIB-ENDIAN_BINARY) $(STDINT_BINARY) $(RESULT_BINARY) | $(CAPNP_OCAML_DIR)
	cd $| && $(DUNE_INSTALL)

capnp-ocaml: $(CAPNP_BINARY) $(CAPNP_OCAML_BINARY)
.PHONY: capnp-ocaml

clean::
	-rm -Rf $(CAPNP_OCAML_DIR)

# ---- ocaml compiler libs ----
OCAML_COMPILER_LIBS_VERSION=0.12.4
OCAML_COMPILER_LIBS_BINARY=$(PREFIX)/lib/ocaml/ocaml-compiler-libs/toplevel/ocaml_toplevel.cmxa

ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION).tar.gz:
	./download $@ https://github.com/janestreet/ocaml-compiler-libs/archive/refs/tags/v$(OCAML_COMPILER_LIBS_VERSION).tar.gz f4c37daf975b67c1f645a5d0294ec8ca686b982da410d9f915ccd93548c6e2f1

ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION): ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION).tar.gz
	tar xzf $<

$(OCAML_COMPILER_LIBS_BINARY): $(DUNE_BINARY) | ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION)
	cd $| && $(DUNE_INSTALL)

ocaml-compiler-libs: $(OCAML_COMPILER_LIBS_BINARY)
.PHONY: ocaml-compiler-libs

clean::
	-rm -Rd ocaml-compiler-libs-$(OCAML_COMPILER_LIBS_VERSION)

# ---- stdlib-shims ----
STDLIB-SHIMS_VERSION=0.3.0
STDLIB-SHIMS_BINARY=$(PREFIX)/lib/ocaml/stdlib-shims/stdlib_shims.cmxa

stdlib-shims-$(STDLIB-SHIMS_VERSION).tar.gz:
	./download $@ https://github.com/ocaml/stdlib-shims/archive/refs/tags/$(STDLIB-SHIMS_VERSION).tar.gz 6d0386313a021146300011549180fcd4e94f7ac3c3bf021ff165f6558608f0c2

stdlib-shims-$(STDLIB-SHIMS_VERSION): stdlib-shims-$(STDLIB-SHIMS_VERSION).tar.gz
	tar xzf $<

$(STDLIB-SHIMS_BINARY): $(DUNE_BINARY) | stdlib-shims-$(STDLIB-SHIMS_VERSION)
	cd $| && $(DUNE_INSTALL)

stdlib-shims: $(STDLIB-SHIMS_BINARY)
.PHONY: stdlib-shims

clean::
	-rm -Rf stdlib-shims-$(STDLIB-SHIMS_VERSION)

# ---- ppx derivers ----
PPX_DERIVERS_VERSION=1.2.1
PPX_DERIVERS_BINARY=$(PREFIX)/lib/ocaml/ppx_derivers/ppx_derivers.cmxa

ppx_derivers-$(PPX_DERIVERS_VERSION).tar.gz:
	./download $@ https://github.com/ocaml-ppx/ppx_derivers/archive/refs/tags/$(PPX_DERIVERS_VERSION).tar.gz b6595ee187dea792b31fc54a0e1524ab1e48bc6068d3066c45215a138cc73b95

ppx_derivers-$(PPX_DERIVERS_VERSION): ppx_derivers-$(PPX_DERIVERS_VERSION).tar.gz
	tar xzf $<

$(PPX_DERIVERS_BINARY): $(DUNE_BINARY) | ppx_derivers-$(PPX_DERIVERS_VERSION)
	cd $| && $(DUNE_INSTALL)

ppx_derivers: $(PPX_DERIVERS_BINARY)
.PHONY: ppx_derivers

clean::
	-rm -Rf ppx_derivers-$(PPX_DERIVERS_VERSION)

# ---- ppxlib ----
PPXLIB_VERSION=0.28.0
PPXLIB_BINARY=$(PREFIX)/lib/ocaml/ppxlib/ppxlib.cmxa

ppxlib-$(PPXLIB_VERSION).tar.gz:
	./download $@ https://github.com/ocaml-ppx/ppxlib/archive/refs/tags/$(PPXLIB_VERSION).tar.gz 9340fd70bb0743ab7984df35a6aea16e3fe1a6a8b0d4e885ad7afba9befb2e43

ppxlib-$(PPXLIB_VERSION): ppxlib-$(PPXLIB_VERSION).tar.gz
	tar xzf $<

$(PPXLIB_BINARY): $(DUNE_BINARY) $(STDLIB-SHIMS_BINARY) $(OCAML_COMPILER_LIBS_BINARY) $(PPX_DERIVERS_BINARY) $(SEXPLIB0_BINARY) | ppxlib-$(PPXLIB_VERSION)
	cd $| && $(DUNE_INSTALL)

ppxlib: $(PPXLIB_BINARY)
.PHONY: ppxlib

clean::
	-rm -Rf ppxlib-$(PPXLIB_VERSION)

# ---- ppx parser ----
PPX_PARSER_VERSION=0.1.0
PPX_PARSER_BINARY=$(PREFIX)/lib/ocaml/ppx_parser/ppx_parser.cmxa

ppx_parser-$(PPX_PARSER_VERSION).tar.gz:
	./download $@ https://github.com/NielsMommen/ppx_parser/archive/refs/tags/$(PPX_PARSER_VERSION).tar.gz 42007eb6dfd7c6cdc02a4acae8a4d48626ba06fca4d5590aeeb1420943d0dc79

ppx_parser-$(PPX_PARSER_VERSION): ppx_parser-$(PPX_PARSER_VERSION).tar.gz
	tar xzf $<

$(PPX_PARSER_BINARY): $(DUNE_BINARY) $(PPXLIB_BINARY) $(CAMLP_STREAMS_BINARY) | ppx_parser-$(PPX_PARSER_VERSION)
	cd $| && $(DUNE_INSTALL)

ppx_parser: $(PPX_PARSER_BINARY)
.PHONY: ppx_parser

clean::
	-rm -Rf ppx_parser-$(PPX_PARSER_VERSION)
	
