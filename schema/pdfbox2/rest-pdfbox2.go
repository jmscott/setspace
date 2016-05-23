package main

import (
	"fmt"
	"html"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"runtime"
	"time"
)

var listen string = ":8080";

var (
	stderr = os.NewFile(uintptr(syscall.Stderr), "/dev/stderr")
	stdout = os.NewFile(uintptr(syscall.Stdout), "/dev/stdout")
)

func usage() {
	fmt.Fprintf(stderr, "usage: rest-pdfbox2\n")
}

func ERROR(format string, args ...interface{}) {

	fmt.Fprintf(
		stderr,
		"%s: rest-pdfbox2: ERROR: %s\n",
		time.Now().Format("2006/01/02 15:04:05"),
		fmt.Sprintf(format, args...),
	)
}

func log(format string, args ...interface{}) {

	fmt.Fprintf(stdout, "%s: %s\n",
		time.Now().Format("2006/01/02 15:04:05"),
		fmt.Sprintf(format, args...),
	)
}

func leave(status int) {
	log("good bye, cruel world")
	os.Exit(status);
}

func main() {

	log("hello, world");

	log("process id: %d", os.Getpid())
	log("go version: %s", runtime.Version())
	log("listen service: %s", listen)

	go func() {
		c := make(chan os.Signal)
		signal.Notify(c, syscall.SIGTERM)
		s := <-c
		log("caught signal: %s", s)
		leave(0)
	}()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, %q", html.EscapeString(r.URL.Path))
	})

	err := http.ListenAndServe(listen, nil)
	if err != nil {
		ERROR("%s", err)
		leave(64)
	}
	leave(0)
}
