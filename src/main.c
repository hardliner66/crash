#include <signal.h>

void func5() {
    raise(SIGSEGV);
}

void func4() {
    func5();
}

void func3() {
    func4();
}

void func2() {
    func3();
}

void func1() {
    func2();
}

int main()
{
    func1();
}
