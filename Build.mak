# Set of flags required to compile vibe.d without dub
override DFLAGS += -version=VibeLibeventDriver -version=Have_openssl \
	-I./submodules/vibed/source -I./submodules/libevent -I./submodules/openssl

# Set of flags required to compile D-YAML without dub
override DFLAGS += -I./submodules/d-yaml/source -I./submodules/tinyendian/source

# Compile all vibe.d as a single static library because rdmd can't track
# all imported dependencies correctly in this case. Static library approach
# instead of compiling all sources in one go was chosen to reduce recompilation
# time for actual apps in this repo.
$O/libvibed.a: $(shell find $C/submodules/vibed/source -type f -name '*.d')
	$(call exec, dmd $(DFLAGS) -lib -of$@ $?)

# Same for D-YAML
$O/libdyaml.a: $(shell find $C/submodules/d-yaml/source -type f -name '*.d') \
		$(shell find $C/submodules/tinyendian/source -type f -name '*.d')
	$(call exec, dmd $(DFLAGS) -lib -of$@ $?)

################################################################################

$O/%unittests: override LDFLAGS += -L$O -lvibed -ldyaml -levent -lssl -lcrypto
$O/pkg-neptune.stamp: release overview

test: $O/libvibed.a $O/libdyaml.a

$B/neptune-overview: $O/libvibed.a $O/libdyaml.a
$B/neptune-overview: $C/src/overview/main.d
$B/neptune-overview: override LDFLAGS += -L$O -lvibed -ldyaml -levent -lssl -lcrypto

$B/neptune-release: override LDFLAGS += -L$O -lvibed -levent -lssl -lcrypto
$B/neptune-release: $C/src/release/main.d $O/libvibed.a

release: $B/neptune-release
overview: $B/neptune-overview

all += release overview
