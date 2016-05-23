//rest service for pdfbox2 schema.  do /pdfbox2/help for details
package main

import (
	"fmt"
	"html"
	"io/ioutil"
	"net/http"
	"os"
	"os/signal"
	"runtime"
	"syscall"
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

func die(format string, args ...interface{}) {

	ERROR(format, args)
	leave(2)
}

func slurp_file(path string) string {
	
	buf, err := ioutil.ReadFile(path)
	if err != nil {
		die("%s", err)
	}
	return string(buf)
}

func main() {

	log("hello, world");

	if len(os.Args) != 1 {
		die(
			"wrong number of arguments: got %d, expected 1",
			len(os.Args),
		)
	}

	log("process id: %d", os.Getpid())
	log("go version: %s", runtime.Version())
	log("listen service: %s", listen)

	//  catch signals

	go func() {
		c := make(chan os.Signal)
		signal.Notify(c, syscall.SIGTERM)
		signal.Notify(c, syscall.SIGQUIT)
		signal.Notify(c, syscall.SIGINT)
		s := <-c
		log("caught signal: %s", s)
		leave(0)
	}()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {

		fmt.Fprintf(w, "Not Found: %q", html.EscapeString(r.URL.Path))
	})

	err := http.ListenAndServe(listen, nil)
	if err != nil {
		die("%s", err)
	}
	leave(0)
}
