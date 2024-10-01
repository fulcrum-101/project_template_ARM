#Toolchain configuration
CC := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy
SIZE := arm-none-eabi-size

#Project configuration
TARGET := main
SRC_DIR := ./src
CMSIS_CORE_DIR := ./lib/CMSIS
CMSIS_DEV_DIR := ./lib/STM32F4xx
INC_DIR := ./Include
LD_SCRIPT = STM32F411VET6.ld

SRC_FILES := $(wildcard $(SRC_DIR)/*.c)
SRC_FILES += $(CMSIS_DEV_DIR)/Sources/system_stm32f4xx.c 
ASM_FILES := $(CMSIS_DEV_DIR)/Sources/startup_stm32f411xe.s



BUILD_DIR := ./build
OBJ_FILES := $(SRC_FILES:%.c=$(BUILD_DIR)/%.o)
ASM_OBJ_FILES := $(ASM_FILES:%.s=$(BUILD_DIR)/%.o)

#$(info SRC $(SRC_FILES))
#$(info OBJ $(OBJ_FILES))
#$(info ASMOBJ $(ASM_OBJ_FILES))

#Preprocessor flags
CPPFLAGS := -DSTM32F411xE
CPPFLAGS += -I$(CMSIS_CORE_DIR)/Include
CPPFLAGS += -I$(CMSIS_DEV_DIR)/Include
CPPFLAGS += -I$(INC_DIR)

#Compiler flags
CFLAGS := -Wall -g3 -O0
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += --specs=nano.specs

#Linker flags
LDFLAGS := -T$(LD_SCRIPT)
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mthumb
LDFLAGS += --specs=nano.specs
LDFLAGS += -Wl,--gc-sections

all: $(TARGET).bin

$(TARGET).bin: $(TARGET).elf
	@$(OBJCOPY) -O binary $< $@

$(TARGET).elf: $(OBJ_FILES) $(ASM_OBJ_FILES)
	$(CC) $^ $(LDFLAGS) -o $@
	$(SIZE) --format=GNU $@

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.s
	mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR) *.elf *.bin
