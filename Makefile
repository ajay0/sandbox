CC = gcc
CFLAGS = -pthread -lm -lseccomp -Wall

EXEC_PATH = $(BIN_DIR)/sandbox
SRC_DIR = src
INCLUDES_DIR = includes
OBJ_DIR = obj
BIN_DIR = bin

OBJ_FILES = $(addprefix $(OBJ_DIR)/, main.o resource_limits.o sandbox.o syscall_manager.o terminate.o)

.PHONY: all clean test

all: $(OBJ_FILES)
	$(CC) -o $(EXEC_PATH) $(OBJ_FILES) $(CFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(INCLUDES_DIR)/*
	$(CC) -o $@ -c -I $(INCLUDES_DIR) $< $(CFLAGS)

test:
	chmod u+x tests/integration_tests/run_tests.sh
	tests/integration_tests/run_tests.sh

clean:
	rm -f $(OBJ_DIR)/* $(BIN_DIR)/*