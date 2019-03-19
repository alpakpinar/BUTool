#PackagePath = $(shell pwd)

RUNTIME_LDPATH=${PWD}

#Exception class
LIBRARY_EXCEPTION = lib/libToolException.so
LIBRARY_EXCEPTION_SOURCES  = $(wildcard src/BUException/*.cc)
LIBRARY_EXCEPTION_OBJECT_FILES = $(patsubst src/%.cc,obj/%.o,${LIBRARY_EXCEPTION_SOURCES})


LIBRARY_TOOL = lib/libBUTool.so
LIBRARY_TOOL_SOURCES  = $(wildcard src/tool/*.cc)
LIBRARY_TOOL_OBJECT_FILES = $(patsubst src/%.cc,obj/%.o,${LIBRARY_TOOL_SOURCES})

LIBRARY_HELPERS = lib/libBUTool_Helpers.so
LIBRARY_HELPERS_SOURCES  = $(wildcard src/helpers/*.cc)
LIBRARY_HELPERS_SOURCES += $(wildcard src/helpers/StatusDisplay/*.cc)
LIBRARY_HELPERS_OBJECT_FILES = $(patsubst src/%.cc,obj/%.o,${LIBRARY_HELPERS_SOURCES})

LIBRARY_WIBDEVICE = lib/libBUTool_WIBDevice.so
LIBRARY_WIBDEVICE_SOURCES = $(wildcard src/wib_device/*.cc)
LIBRARY_WIBDEVICE_OBJECT_FILES = $(patsubst src/%.cc,obj/%.o,${LIBRARY_WIBDEVICE_SOURCES})

EXECUTABLE_SOURCES = $(wildcard src/tool/*.cxx)
EXECUTABLE_OBJECT_FILES = $(patsubst src/%.cxx,obj/%.o,${EXECUTABLE_SOURCES})
EXECUTABLES = $(patsubst src/%.cxx,bin/%.exe,${EXECUTABLE_SOURCES})

INCLUDE_PATH = \
							-Iinclude  

LIBRARY_PATH = \
							-Llib 

ifdef BOOST_INC
INCLUDE_PATH +=-I$(BOOST_INC)
endif
ifdef BOOST_LIB
LIBRARY_PATH +=-L$(BOOST_LIB)
endif

LIBRARIES =    	-lToolException	\
		-lreadline 			\
		-lcurses 			\
		-lz 				\
		-lboost_regex




EXECUTABLE_LINKED_LIBRARIES = ${LIBRARY_TOOL} ${LIBRARY_HELPERS}
EXECUTABLE_LINKED_LIBRARY_FLAGS = $(patsubst lib%,-l%,$(patsubst %.so,%,$(notdir ${EXECUTABLE_LINKED_LIBRARIES})))

EXECUTABLE_LIBRARIES = ${LIBRARIES} ${EXECUTABLE_LINKED_LIBRARY_FLAGS} 


CPP_FLAGS = -g -O3 -rdynamic -Wall -MMD -MP -fPIC ${INCLUDE_PATH} -Werror -Wno-literal-suffix

#CPP_FLAGS += -std=c++11 -fno-omit-frame-pointer -pedantic -Wno-ignored-qualifiers -Werror=return-type -Wextra -Wno-long-long -Winit-self -Wno-unused-local-typedefs  -Woverloaded-virtual -Wimplicit-fallthrough=2 
CPP_FLAGS += -std=c++11 -fno-omit-frame-pointer -pedantic -Wno-ignored-qualifiers -Werror=return-type -Wextra -Wno-long-long -Winit-self -Wno-unused-local-typedefs  -Woverloaded-virtual

LINK_LIBRARY_FLAGS = -shared -fPIC -Wall -g -O3 -rdynamic ${LIBRARY_PATH} ${LIBRARIES}

LINK_EXECUTABLE_FLAGS = -Wall -g -O3 -rdynamic ${LIBRARY_PATH} ${EXECUTABLE_LIBRARIES} -Wl,-rpath=${RUNTIME_LDPATH}/lib




.PHONY: all _all clean _cleanall build _buildall

default: build
clean: _cleanall
_cleanall:
	rm -rf obj
	rm -rf bin
	rm -rf lib


all: _all
build: _all
buildall: _all
_all: ${EXECUTABLE_LINKED_LIBRARIES} ${LIBRARY_HELPERS} ${LIBRARY_TOOL}  ${EXECUTABLES} 

# ------------------------
# exception library
# ------------------------
${LIBRARY_EXCEPTION}: ${LIBRARY_EXCEPTION_OBJECT_FILES}
	mkdir -p $(dir $@)
	g++ -shared -fPIC -Wall -g -O3 -rdynamic ${LIBRARY_EXCEPTION_OBJECT_FILES} -o $@

${LIBRARY_EXCEPTION_OBJECT_FILES}: obj/%.o : src/%.cc 
	mkdir -p $(dir $@)
	g++ ${CPP_FLAGS} -c $< -o $@


# ------------------------
# Executables
# ------------------------
${EXECUTABLES}: bin/%.exe: obj/%.o ${EXECUTABLE_OBJECT_FILES}  ${LIBRARY_TOOL}  ${EXECUTABLE_LINKED_LIBRARIES} ${LIBRARY_HELPERS}
	mkdir -p $(dir $@)
	g++ ${LINK_EXECUTABLE_FLAGS} $< -o $@

${EXECUTABLE_OBJECT_FILES}: obj/%.o : src/%.cxx
	mkdir -p $(dir $@)
	g++ -c ${CPP_FLAGS}  $< -o $@

-include $(EXECUTABLE_OBJECT_FILES:.o=.d)

# ------------------------
# tool library
# ------------------------
${LIBRARY_TOOL}: ${LIBRARY_TOOL_OBJECT_FILES} ${LIBRARY_EXCEPTION}
	mkdir -p $(dir $@)
	g++ ${LINK_LIBRARY_FLAGS} ${LIBRARY_TOOL_OBJECT_FILES} -o $@

${LIBRARY_TOOL_OBJECT_FILES}: obj/%.o : src/%.cc 
	mkdir -p $(dir $@)
	g++ ${CPP_FLAGS} -c $< -o $@

# ------------------------
# helpers library
# ------------------------
${LIBRARY_HELPERS}: ${LIBRARY_HELPERS_OBJECT_FILES} ${LIBRARY_EXCEPTION}
	mkdir -p $(dir $@)
	g++ ${LINK_LIBRARY_FLAGS} ${LIBRARY_HELPERS_OBJECT_FILES} -o $@

${LIBRARY_HELPERS_OBJECT_FILES}: obj/%.o : src/%.cc 
	mkdir -p $(dir $@)
	g++ ${CPP_FLAGS} ${UHAL_CPP_FLAGHS} -c $< -o $@

-include $(LIBRARY_OBJECT_FILES:.o=.d)

