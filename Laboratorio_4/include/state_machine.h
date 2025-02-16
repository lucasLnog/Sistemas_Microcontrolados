
enum State {
	STARTUP,
	CLI_CTL,
	POT_CTL,
};

enum State switch_state(char input);

void exec_state();

void execute_machine();
