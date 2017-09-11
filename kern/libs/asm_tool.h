int io_load_eflags(void);
void io_store_eflags(int eflags);
int io_in8(int port);
void io_out8(int port, int data);

void io_cli(void);
void io_sti(void);