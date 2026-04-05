CXX := g++
CXXFLAGS := -std=c++17 -O2 -Wall -Wextra -pedantic
LDFLAGS := -static
GTK_CFLAGS := $(shell pkg-config --cflags gtk+-3.0 2>/dev/null)
GTK_LIBS := $(shell pkg-config --static --libs gtk+-3.0 2>/dev/null)

TARGET := ocho_gui_cpp
SRC := ocho_gui_cpp.cpp

.PHONY: all clean check-deps

all: check-deps $(TARGET)

check-deps:
	@if ! pkg-config --exists gtk+-3.0; then \
		echo "Error: gtk+-3.0 development package not found via pkg-config."; \
		echo "Install GTK3 dev files (e.g. libgtk-3-dev) and retry."; \
		exit 1; \
	fi

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $(GTK_CFLAGS) $(LDFLAGS) -o $@ $< $(GTK_LIBS)

clean:
	rm -f $(TARGET)
