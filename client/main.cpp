#include <stdio.h>	    
#include <fcntl.h>
#include <io.h>	  
#include <vector>
#include "stdinput.h"
#include "launch.h"
#include "attach.h"
#include "server.h"
#include "dbg_capabilities.h"
#include <base/util/unicode.h>
#include <base/util/unicode.cpp>
#include <base/file/stream.cpp>
#include <base/filesystem.h>
#include "dbg_iohelper.h"
#include "dbg_iohelper.cpp"

bool create_process_with_debugger(vscode::rprotocol& req, uint16_t port);

uint16_t server_port = 0;
int64_t seq = 1;

void response_initialized(stdinput& io, vscode::rprotocol& req)
{
	vscode::wprotocol res;

	for (auto _ : res.Object())
	{
		res("type").String("response");
		res("seq").Int64(1);
		res("command").String("initialize");
		res("request_seq").Int64(req["seq"].GetInt64());
		res("success").Bool(true);
		vscode::capabilities(res);
	}
	vscode::io_output(&io, res);
}

void response_error(stdinput& io, vscode::rprotocol& req, const char *msg)
{
	vscode::wprotocol res;
	for (auto _ : res.Object())
	{
		res("type").String("response");
		res("seq").Int64(seq++);
		res("command").String(req["command"]);
		res("request_seq").Int64(req["seq"].GetInt64());
		res("success").Bool(false);
		res("message").String(msg);
	}
	vscode::io_output(&io, res);
}

int stoi_nothrow(std::string const& str)
{
	try {
		return std::stoi(str);
	}
	catch (...) {
	}
	return 0;
}

int run_launch(stdinput& io, vscode::rprotocol& init, vscode::rprotocol& req)
{
	launch launch(io);
	launch.request_launch(req);
	if (seq > 1) init.AddMember("__initseq", seq, init.GetAllocator());
	launch.send(std::move(init));
	launch.send(std::move(req));
	for (;; std::this_thread::sleep_for(std::chrono::milliseconds(10))) {
		launch.update();
	}
	return 0;
}

int main()
{
	MessageBox(0,0,0,0);
	_setmode(_fileno(stdout), _O_BINARY);
	setbuf(stdout, NULL);

	stdinput io;
	vscode::rprotocol initproto;
	vscode::rprotocol connectproto;
	std::unique_ptr<attach> attach_;
	std::unique_ptr<launch> launch_;
	std::unique_ptr<server> server_;

	for (;; std::this_thread::sleep_for(std::chrono::milliseconds(10))) {
		if (launch_) {
			launch_->update();
			continue;
		}
		if (attach_) {
			attach_->update();
			continue;
		}
		if (server_) {
			server_->update();
			continue;
		}
		for (;;) {
			vscode::rprotocol rp = vscode::io_input(&io);
			if (rp.IsNull()) {
				break;
			}
			if (rp["type"] != "request") {
				continue;
			}
			if (rp["command"] == "initialize") {
				response_initialized(io, rp);
				initproto = std::move(rp);
				initproto.AddMember("__norepl", true, initproto.GetAllocator());
				seq = 1;
				continue;
			}
			else if (rp["command"] == "launch") {
				auto& args = rp["arguments"];
				if (args.HasMember("runtimeExecutable")) {
					if (!server_) {
						server_.reset(new server("127.0.0.1", 0));
						server_->event_recv([&](const std::string& msg) {
							uint16_t port = stoi_nothrow(msg);
							if (!port) {
								response_error(io, connectproto, "Launch failed");
								exit(0);
								return;
							}
							attach_.reset(new attach(io));
							attach_->connect(net::endpoint("127.0.0.1", port));
							if (seq > 1) initproto.AddMember("__initseq", seq, initproto.GetAllocator());
							attach_->send(initproto);
							attach_->send(connectproto);
						});
						server_port = wait_ok(server_.get());
						if (!server_port) {
							response_error(io, rp, "Launch failed");
							exit(0);
							continue;
						}
					}
					if (!create_process_with_debugger(rp, server_port)) {
						response_error(io, rp, "Launch failed");
						exit(0);
						continue;
					}
					connectproto = std::move(rp);
				}
				else {
					return run_launch(io, initproto, rp);
				}
			}
			else if (rp["command"] == "attach") {
				attach_.reset(new attach(io));
				auto& args = rp["arguments"];
				std::string ip = args.HasMember("ip") ? args["ip"].Get<std::string>() : "127.0.0.1";
				uint16_t port = args.HasMember("port") ? args["port"].GetUint() : 4278;
				attach_->connect(net::endpoint(ip, port));
				if (seq > 1) initproto.AddMember("__initseq", seq, initproto.GetAllocator());
				attach_->send(initproto);
				attach_->send(rp);
			}
		}
	}
	io.join();
}
