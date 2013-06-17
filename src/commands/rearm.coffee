Q = require 'q'
cli = require '../cli'

module.exports = (program) -> program
  .command('rearm [names]')
  .description('rearm virtual machines')
  .option('-E, --no-expired', 'rearm the even if not expired')
  .action (names, command) ->
    msg = if command.expired then 'no matching expired virtual machines found'

    # Start a VM with a bit of delay for networking.
    start = (vm) -> vm.start(true).then -> Q.delay(5000).then ->

    cli.fail cli.find(names, '!missing').maybeWhere(command.expired, 'expired')
      .found(msg).then (vms) ->
        cli.dsl(vms).where('!running').then (stopped) ->
          cli.dsl(stopped).all(start).then ->
            cli.dsl(vms).all((vm) -> vm.rearm()).then ->
              cli.dsl(stopped).all (vm) -> vm.stop()