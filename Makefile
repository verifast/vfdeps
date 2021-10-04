PATH:=$(PREFIX)/bin:$(PATH)
JOBS?=1

all: ocaml findlib num ocamlbuild camlp4 lablgtk z3 dune csexp sexplib0 base res stdio cppo ocplib-endian stdint result capnp capnp-ocaml

# ---- OCaml ----

OCAML_VERSION=4.13.0
OCAML_BINARY=$(PREFIX)/bin/ocamlopt.opt

ocaml-$(OCAML_VERSION).tar.gz:
	curl -L https://github.com/ocaml/ocaml/archive/$(OCAML_VERSION).tar.gz > ocaml-$(OCAML_VERSION).tar.gz

ocaml-$(OCAML_VERSION): ocaml-$(OCAML_VERSION).tar.gz
	tar xzf ocaml-$(OCAML_VERSION).tar.gz

$(OCAML_BINARY): | ocaml-$(OCAML_VERSION)
	cd ocaml-$(OCAML_VERSION) && \
        ./configure -prefix $(PREFIX) && \
        make world.opt && \
        make install

ocaml: $(OCAML_BINARY)
.PHONY: ocaml

clean::
	-rm -Rf ocaml-$(OCAML_VERSION)

# ---- Findlib ----

FINDLIB_VERSION=1.9.1
FINDLIB_BINARY=$(PREFIX)/bin/ocamlfind

findlib-$(FINDLIB_VERSION).tar.gz:
	curl -L http://download.camlcity.org/download/findlib-$(FINDLIB_VERSION).tar.gz > findlib-$(FINDLIB_VERSION).tar.gz

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
	curl -Lfo num-$(NUM_VERSION).tar.gz https://github.com/ocaml/num/archive/v$(NUM_VERSION).tar.gz

num-$(NUM_VERSION): num-$(NUM_VERSION).tar.gz
	tar xzf num-$(NUM_VERSION).tar.gz

$(NUM_BINARY): $(FINDLIB_BINARY) | num-$(NUM_VERSION)
	cd num-$(NUM_VERSION) && make all && make install

num: $(NUM_BINARY)
.PHONY: num

clean::
	-rm -Rf num-$(NUM_VERSION)

# ---- ocamlbuild ----

OCAMLBUILD_VERSION=0.14.0
OCAMLBUILD_BINARY=$(PREFIX)/bin/ocamlbuild

ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz:
	curl -Lfo ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz https://github.com/ocaml/ocamlbuild/archive/$(OCAMLBUILD_VERSION).tar.gz

ocamlbuild-$(OCAMLBUILD_VERSION): ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz
	tar xzf ocamlbuild-$(OCAMLBUILD_VERSION).tar.gz

$(OCAMLBUILD_BINARY): $(FINDLIB_BINARY) | ocamlbuild-$(OCAMLBUILD_VERSION)
	cd ocamlbuild-$(OCAMLBUILD_VERSION) && \
        make configure && make && make install

ocamlbuild: $(OCAMLBUILD_BINARY)
.PHONY: ocamlbuild

clean::
	-rm -Rf ocamlbuild-$(OCAMLBUILD_VERSION)

# ---- camlp4 ----

CAMLP4_VERSION:=4.13+1
CAMLP4_DIR:=camlp4-$(subst +,-,$(CAMLP4_VERSION))
CAMLP4_BINARY:=$(PREFIX)/bin/camlp4o

$(CAMLP4_DIR).tar.gz:
	curl -Lfo $(CAMLP4_DIR).tar.gz https://github.com/ocaml/camlp4/archive/$(CAMLP4_VERSION).tar.gz

$(CAMLP4_DIR): $(CAMLP4_DIR).tar.gz
	tar xzf $(CAMLP4_DIR).tar.gz

$(CAMLP4_BINARY): $(OCAMLBUILD_BINARY) | $(CAMLP4_DIR)
	cd $(CAMLP4_DIR) && \
        ./configure && make all && make install

camlp4: $(CAMLP4_BINARY)
.PHONY: camlp4

clean::
	-rm -Rf $(CAMLP4_DIR)

# ---- lablgtk ----

LABLGTK_VERSION=2.18.11
LABLGTK_BINARY=$(PREFIX)/lib/ocaml/lablgtk2/lablgtk.cmxa

lablgtk-$(LABLGTK_VERSION).tar.gz:
	curl -Lfo lablgtk-$(LABLGTK_VERSION).tar.gz https://github.com/garrigue/lablgtk/archive/refs/tags/$(LABLGTK_VERSION).tar.gz

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
	curl -Lfo z3-$(Z3_VERSION).tar.gz https://github.com/Z3Prover/z3/archive/Z3-$(Z3_VERSION).tar.gz

$(Z3_DIR): z3-$(Z3_VERSION).tar.gz
	tar xzf z3-$(Z3_VERSION).tar.gz

$(Z3_BINARY): $(FINDLIB_BINARY) | $(Z3_DIR)
	cd $(Z3_DIR) && \
        python scripts/mk_make.py --ml --prefix=$(PREFIX) && \
        cd build && make && make install

z3: $(Z3_BINARY)
.PHONY: z3

clean::
	-rm -Rf $(Z3_DIR)

# ---- dune ----
DUNE_VERSION=2.9.1
DUNE_BINARY=$(PREFIX)/bin/dune
DUNE_CONF_BINARY=$(PREFIX)/lib/ocaml/dune-configurator/configurator.cmxa

dune-$(DUNE_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/ocaml/dune/archive/refs/tags/$(DUNE_VERSION).tar.gz

dune-$(DUNE_VERSION): dune-$(DUNE_VERSION).tar.gz
	tar xzf $<

$(DUNE_BINARY): | dune-$(DUNE_VERSION)
	cd $| && ./configure --libdir=$(PREFIX)/lib/ocaml && make release && make install

$(DUNE_CONF_BINARY): $(DUNE_BINARY) $(SEXPLIB0_BINARY) | dune-$(DUNE_VERSION)
	cd $| && ./dune.exe build @install && ./dune.exe install

dune: $(DUNE_BINARY)
.PHONY: dune

clean::
	-rm -Rf dune-$(DUNE_VERSION)

# ---- csexp ----
CSEXP_VERSION=1.5.1
CSEXP_BINARY=$(PREFIX)/lib/ocaml/csexp/csexp.cmxa

csexp-$(CSEXP_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/ocaml-dune/csexp/archive/refs/tags/$(CSEXP_VERSION).tar.gz

csexp-$(CSEXP_VERSION): csexp-$(CSEXP_VERSION).tar.gz
	tar xzf $<

$(CSEXP_BINARY): $(DUNE_BINARY) | csexp-$(CSEXP_VERSION)
	cd $| && dune build && dune install

csexp: $(CSEXP_BINARY)
.PHONY: csexp

# ---- sexplib0 ----
SEXPLIB0_VERSION=0.14.0
SEXPLIB0_BINARY=$(PREFIX)/lib/ocaml/sexplib0/sexplib0.cmxa

sexplib0-$(SEXPLIB0_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/janestreet/sexplib0/archive/refs/tags/v$(SEXPLIB0_VERSION).tar.gz

sexplib0-$(SEXPLIB0_VERSION): sexplib0-$(SEXPLIB0_VERSION).tar.gz
	tar xzf $<

$(SEXPLIB0_BINARY): $(DUNE_BINARY) $(DUNE_CONF_BINARY) | sexplib0-$(SEXPLIB0_VERSION)
	cd $| && dune build && dune install

sexplib0: $(SEXPLIB0_BINARY)
.PHONY: sexplib0

clean::
	-rm -Rf sexplib0-$(SEXPLIB0_VERSION)

# ---- base ----
BASE_VERSION=0.14.1
BASE_BINARY=$(PREFIX)/lib/ocaml/base/base.cmxa

base-$(BASE_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/janestreet/base/archive/refs/tags/v$(BASE_VERSION).tar.gz

base-$(BASE_VERSION): base-$(BASE_VERSION).tar.gz
	tar xzf $<

$(BASE_BINARY): $(DUNE_BINARY) $(SEXPLIB0_BINARY) | base-$(BASE_VERSION)
	cd $| && dune build && dune install

base: $(SEXPLIB0_BINARY) $(BASE_BINARY)
.PHONY: base

clean::
	-rm -Rf base-$(BASE_VERSION)

# ---- res ----
RES_VERSION=5.0.1
RES_BINARY=$(PREFIX)/lib/ocaml/res/res.cmxa

res-$(RES_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/mmottl/res/archive/refs/tags/$(RES_VERSION).tar.gz

res-$(RES_VERSION): res-$(RES_VERSION).tar.gz
	tar xzf $<

$(RES_BINARY): $(DUNE_BINARY) | res-$(RES_VERSION)
	cd $| && dune build && dune install

res: $(RES_BINARY)
.PHONY: res

clean::
	-rm -Rf res-$(RES_VERSION)

# ---- stdio ----
STDIO_VERSION=0.14.0
STDIO_BINARY=$(PREFIX)/lib/ocaml/stdio/stdio.cmxa

stdio-$(STDIO_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/janestreet/stdio/archive/refs/tags/v$(STDIO_VERSION).tar.gz

stdio-$(STDIO_VERSION): stdio-$(STDIO_VERSION).tar.gz
	tar xzf $<

$(STDIO_BINARY): $(DUNE_BINARY) $(BASE_BINARY) | stdio-$(STDIO_VERSION)
	cd $| && dune build && dune install

stdio: $(STDIO_BINARY)
.PHONY: stdio

clean::
	-rm -Rf stdio-$(STDIO_VERSION)

# ---- cppo ----
CPPO_VERSION=1.6.8
CPPO_BINARY=$(PREFIX)/bin/cppo

cppo-$(CPPO_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/ocaml-community/cppo/archive/refs/tags/v$(CPPO_VERSION).tar.gz

cppo-$(CPPO_VERSION): cppo-$(CPPO_VERSION).tar.gz
	tar xzf $<

$(CPPO_BINARY): $(DUNE_BINARY) | cppo-$(CPPO_VERSION)
	cd $| && dune build && dune install

cppo: $(CPPO_BINARY)
.PHONY: cppo

clean::
	-rm -Rf cppo-$(CPPO_VERSION)

# ---- ocplib-endian ----
OCPLIB-ENDIAN_VERSION=1.1
OCPLIB-ENDIAN_BINARY=$(PREFIX)/lib/ocaml/ocplib-endian/ocplib-endian.cmxa

ocplib-endian-$(OCPLIB-ENDIAN_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/OCamlPro/ocplib-endian/archive/$(OCPLIB-ENDIAN_VERSION).tar.gz

ocplib-endian-$(OCPLIB-ENDIAN_VERSION): ocplib-endian-$(OCPLIB-ENDIAN_VERSION).tar.gz
	tar xzf $<

$(OCPLIB-ENDIAN_BINARY): $(DUNE_BINARY) $(CPPO_BINARY) | ocplib-endian-$(OCPLIB-ENDIAN_VERSION)
	cd $| && dune build && dune install

ocplib-endian: $(OCPLIB-ENDIAN_BINARY)
.PHONY: ocplib-endian

clean::
	-rm -Rf ocplib-endian-$(OCPLIB-ENDIAN_VERSION)

# ---- stdint ----
STDINT_VERSION=0.7.0
STDINT_DIR=ocaml-stdint-$(STDINT_VERSION)
STDINT_BINARY=$(PREFIX)/lib/ocaml/stdint/stdint.cmxa

stdint-$(STDINT_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/andrenth/ocaml-stdint/archive/refs/tags/$(STDINT_VERSION).tar.gz

$(STDINT_DIR): stdint-$(STDINT_VERSION).tar.gz
	tar xzf $<

$(STDINT_BINARY): $(DUNE_BINARY) | $(STDINT_DIR)
	cd $| && dune build && dune install

stdint: $(STDINT_BINARY)
.PHONY: stdint

clean::
	-rm -Rf stdint-$(STDINT_VERSION)

# ---- result ----
RESULT_VERSION=1.5
RESULT_BINARY=$(PREFIX)/lib/ocaml/result/result.cmxa

result-$(RESULT_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/janestreet/result/archive/refs/tags/$(RESULT_VERSION).tar.gz

result-$(RESULT_VERSION): result-$(RESULT_VERSION).tar.gz
	tar xzf $<

$(RESULT_BINARY): $(DUNE_BINARY) | result-$(RESULT_VERSION)
	cd $| && dune build && dune install

result: $(RESULT_BINARY)
.PHONY: result

clean::
	-rm -Rf result-$(RESULT_VERSION)

# ---- cap'n proto ----
## capnp tool to produce stubs code based on .capnp schema files, also installs the C++ plugin to create C++ stubs
CAPNP_VERSION=0.9.1
CAPNP_DIR=capnproto-c++-$(CAPNP_VERSION)
CAPNP_BINARY=$(PREFIX)/bin/capnp

capnp-$(CAPNP_VERSION).tar.gz:
	curl -Lfo $@ https://capnproto.org/capnproto-c++-$(CAPNP_VERSION).tar.gz

$(CAPNP_DIR): capnp-$(CAPNP_VERSION).tar.gz
	tar xzf $<

$(CAPNP_BINARY): | $(CAPNP_DIR)
	cd $| && ./configure --prefix=$(PREFIX) && make -j$(JOBS) check && make install

capnp: $(CAPNP_BINARY)
.PHONY: capnp

clean::
	-rm -Rf $(CAPNP_DIR)

## capnp plugin for ocaml, which allows to create stubs code with the capnp tool
CAPNP_OCAML_VERSION=3.4.0
CAPNP_OCAML_DIR=capnp-ocaml-$(CAPNP_OCAML_VERSION)
CAPNP_OCAML_BINARY=$(PREFIX)/lib/ocaml/capnp/capnp.cmxa

capnp-$(CAPNP_OCAML_VERSION).tar.gz:
	curl -Lfo $@ https://github.com/capnproto/capnp-ocaml/archive/refs/tags/v$(CAPNP_OCAML_VERSION).tar.gz

$(CAPNP_OCAML_DIR): capnp-$(CAPNP_OCAML_VERSION).tar.gz
	tar xzf $<

$(CAPNP_OCAML_BINARY): $(DUNE_BINARY) $(BASE_BINARY) $(STDIO_BINARY) $(RES_BINARY) $(OCPLIB-ENDIAN_BINARY) $(RESULT_BINARY) $(STDINT_BINARY) | $(CAPNP_OCAML_DIR)
	cd $| && dune build && dune install

capnp-ocaml: $(CAPNP_BINARY) $(CAPNP_OCAML_BINARY)
.PHONY: capnp-ocaml

clean::
	-rm -Rf $(CAPNP_OCAML_DIR)
