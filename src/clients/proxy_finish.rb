# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006-2012 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:
#  proxy_finish.ycp
#
# Module:
#  Step of base installation finish
#
# Authors:
#  Jiri Srain <jsrain@suse.cz>
#
# $Id$
#
module Yast
  class ProxyFinishClient < Client
    def main

      textdomain "installation"

      Yast.import "Stage"

      @ret = nil
      @func = ""
      @param = {}

      # Check arguments
      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.to_map(WFM.Args(1))
        end
      end

      Builtins.y2milestone("starting proxy_finish")
      Builtins.y2debug("func=%1", @func)
      Builtins.y2debug("param=%1", @param)

      if @func == "Info"
        return {
          "steps" => 1,
          # progress step title
          "title" => _("Saving proxy configuration..."),
          "when"  => [:installation, :update, :autoinst]
        }
      elsif @func == "Write"
        if Stage.initial
          @proxy = Convert.to_string(SCR.Read(path(".etc.install_inf.Proxy")))
          @proxyport = Convert.to_string(
            SCR.Read(path(".etc.install_inf.ProxyPort"))
          )
          @proxyproto = Convert.to_string(
            SCR.Read(path(".etc.install_inf.ProxyProto"))
          )

          if @proxy != nil && @proxyport != nil && @proxyproto != nil
            @fullproxy = Ops.add(
              Ops.add(
                Ops.add(Ops.add(Ops.add(@proxyproto, "://"), @proxy), ":"),
                @proxyport
              ),
              "/"
            )

            Builtins.y2milestone("setting proxy to %1", @fullproxy)

            # maybe use Proxy module
            SCR.Write(path(".sysconfig.proxy.HTTP_PROXY"), @fullproxy)
            SCR.Write(path(".sysconfig.proxy.FTP_PROXY"), @fullproxy)
            SCR.Write(path(".sysconfig.proxy"), nil)
          end
        end
      else
        Builtins.y2error("unknown function: %1", @func)
        @ret = nil
      end

      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("proxy_finish finished")
      deep_copy(@ret)
    end
  end
end

Yast::ProxyFinishClient.new.main
