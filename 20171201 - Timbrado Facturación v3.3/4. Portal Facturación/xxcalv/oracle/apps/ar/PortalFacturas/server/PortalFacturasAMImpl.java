package xxcalv.oracle.apps.ar.PortalFacturas.server;


import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class PortalFacturasAMImpl extends OAApplicationModuleImpl {
    /**This is the default constructor (do not remove)
     */
    public PortalFacturasAMImpl() {
    }

    /**Sample main for debugging Business Components code using the tester.
     */
    public static void main(String[] args) {
        launchTester("xxcalv.oracle.apps.ar.PortalFacturas.server", /* package name */
      "PortalFacturasAMLocal" /* Configuration Name */);
    }

    /**Container's getter for PAC_MASTEREDI_REPORT_VO1
     */
    public PAC_MASTEREDI_REPORT_VOImpl getPAC_MASTEREDI_REPORT_VO1() {
        return (PAC_MASTEREDI_REPORT_VOImpl)findViewObject("PAC_MASTEREDI_REPORT_VO1");
    }

    /**Container's getter for RFCEMIVO1
     */
    public RFCEMIVOImpl getRFCEMIVO1() {
        return (RFCEMIVOImpl)findViewObject("RFCEMIVO1");
    }

    /**Container's getter for RFCRECVO1
     */
    public RFCRECVOImpl getRFCRECVO1() {
        return (RFCRECVOImpl)findViewObject("RFCRECVO1");
    }

    /**Container's getter for SERFOLVO1
     */
    public SERFOLVOImpl getSERFOLVO1() {
        return (SERFOLVOImpl)findViewObject("SERFOLVO1");
    }

    /**Container's getter for TIPDOCVO1
     */
    public TIPDOCVOImpl getTIPDOCVO1() {
        return (TIPDOCVOImpl)findViewObject("TIPDOCVO1");
    }

}
