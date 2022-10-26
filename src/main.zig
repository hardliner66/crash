const c = @cImport({
    // See https://github.com/ziglang/zig/issues/515
    @cInclude("signal.h");
});
const raise = c.raise;
const SIGSEGV = c.SIGSEGV;

fn func5() void {
    _ = raise(SIGSEGV);
}

fn func4() void {
    func5();
}

fn func3() void {
    func4();
}

fn func2() void {
    func3();
}

fn func1() void {
    func2();
}

pub fn main() void {
    func1();
}
