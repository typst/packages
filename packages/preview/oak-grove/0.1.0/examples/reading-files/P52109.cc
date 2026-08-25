
#include <iostream>
using namespace std;

int main() {
    int n;
    while (cin >> n) {
        n = 3 * n + 1;
        while (n % 2 == 0) {
            n /= 2;
        }
        cout << n << '\n';
    }
}