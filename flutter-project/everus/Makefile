.PHONY: all build clean serve stop restart help

BUILD_DIR = build/web
PORT = 8008
LOG_FILE = web.txt

# Default target: clean, build, and start server
all: build serve

# Clean the flutter web output folder
clean:
	@echo "Cleaning output folder $(BUILD_DIR)..."
	rm -rf $(BUILD_DIR)

# Build Flutter web for release
build: clean
	@echo "Building Flutter web..."
	flutter build web --release

# Run nohup python server on port 8008 and pipe log to web.txt
serve:
	@echo "Checking for any existing server process on port $(PORT)..."
	-pkill -f "python3 -m http.server $(PORT)" 2>/dev/null || true
	@echo "Starting nohup Python server on port $(PORT)..."
	nohup python3 -m http.server $(PORT) --directory $(BUILD_DIR) > $(LOG_FILE) 2>&1 &
	@echo "Python server running in background at http://localhost:$(PORT)"
	@echo "Logs piped to $(LOG_FILE)"

# Stop the running python server
stop:
	@echo "Stopping Python server on port $(PORT)..."
	-pkill -f "python3 -m http.server $(PORT)" 2>/dev/null || true

# Rebuild and restart server
restart: build serve

# Display help information
help:
	@echo "Available commands:"
	@echo "  make          - Automatically clean, build web, and start python server"
	@echo "  make build    - Delete build/web and build Flutter web for release"
	@echo "  make serve    - Start background python server on port $(PORT)"
	@echo "  make stop     - Stop the running python server"
	@echo "  make clean    - Remove build/web directory"
