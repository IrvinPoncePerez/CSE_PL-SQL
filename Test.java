package oracle.apps.xxcust.cp.request;
import oracle.apps.fnd.cp.request.*;
public class Test implements JavaConcurrentProgram{
        
        public void runProgram(CpContext ctx){

                // get reference to Out and Log files
                OutFile out = ctx.getOutFile();
                LogFile log = ctx.getLogFile();

                out.writeln("This is my Output file ! ");
                log.writeln("This is my Log file",LogFile.STATEMENT);

                //get concurrent program Request Details
                ReqDetails rDet = ctx.getReqDetails();
                String userName = rDet.getUserInfo().getUserName();
                
                // write username to the Out File
                out.writeln("User Name = "+userName);
                
                // Success message to the Concurrent Manager
                ctx.getReqCompletion().setCompletion(ReqCompletion.NORMAL, "Completed");
        }

}