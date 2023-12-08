//MANUAL DE USUARIO Y MANUAL T�CNICO

package interfaces;

import com.itextpdf.text.Document;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.File;
import java.io.FileOutputStream;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

public class ConvPDF extends javax.swing.JFrame {

    public ConvPDF() {
        initComponents();
    }

    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jPanel1 = new javax.swing.JPanel();
        jLabel1 = new javax.swing.JLabel();
        jButton1 = new javax.swing.JButton();
        jtxtdir = new javax.swing.JTextField();
        jScrollPane1 = new javax.swing.JScrollPane();
        jtxacont = new javax.swing.JTextArea();
        jButton2 = new javax.swing.JButton();
        jButton3 = new javax.swing.JButton();
        jtxtdir2 = new javax.swing.JTextField();
        jScrollPane2 = new javax.swing.JScrollPane();
        jtxacont2 = new javax.swing.JTextArea();
        jButton4 = new javax.swing.JButton();
        jButton5 = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
        setBackground(new java.awt.Color(204, 153, 255));

        jPanel1.setBackground(new java.awt.Color(204, 153, 255));

        jLabel1.setFont(new java.awt.Font("Bahnschrift", 1, 18)); // NOI18N
        jLabel1.setText("A.K.L.K");

        jButton1.setText("Direccion");
        jButton1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton1ActionPerformed(evt);
            }
        });

        jtxtdir.setEditable(false);

        jtxacont.setEditable(false);
        jtxacont.setColumns(20);
        jtxacont.setRows(5);
        jtxacont.setText("-----------------------------| MANUAL DE AYUDA USUARIO |-----------------------------\n\n<<<<<<<<<<<<< | Para iniciar sesi�n o crear cuenta | >>>>>>>>>>>>>>\nSe mostrar� la pantalla principal del sistema. Se pedir� iniciar sesi�n en caso de tener una cuenta ya creada. Se ingresa el usuario y contrase�a, y posteriormente, se mostrar� un mensaje de validaci�n de la cuenta en la pantalla.\n\nEn caso de ser un administrador, para consultar todos los proyectos se dar� click en el bot�n \"Consultar\", lo mismo si se quiere consultar las tareas y participantes, s�lo se deber� colocar en la pesta�a correspondiente. Por otra parte, para agregar alg�n proyecto, tarea o participante se le dar� click en \"Agregar\". Si ya no se requiere hacer ninguna acci�n se dar� click en el bot�n de \"Atr�s\", el cual lo regresar� a la pantalla principal.\n\nDe caso contrario (si no se tiene una cuenta), darle click al bot�n de \"Crear cuenta\". Se llenar�n los datos correspondientes de Nombre, Apellidos, Tel�fono, Correo electr�nico y pa�s. Al dar \"Aceptar\" ya tendr� una cuenta dentro del sistema y podr� iniciar sesi�n.\n\n<<<<<<<<<<<<< | Para agregar participantes | >>>>>>>>>>>>>>>\n\nAntes de haber creado un proyecto posicionarse en la pesta�a de \"Participante\", posteriormente llenar campos y dar click en \"Agregar\". Para ver el participante creado dar click en la pesta�a de \"Participante\" en \"Consultar\".\n\n<<<<<<<<<<<<< | Para crear un proyecto | >>>>>>>>>>>>>>>>>>\n\nDespu�s de haber iniciado sesi�n con la cuenta de usuario posicionarse en la pesta�a de \"Proyecto\" en el bot�n de \"Agregar\", posteriormente llenar campos de Nombre, responsable, etc. Dar click en \"Aceptar\" y para ver el nuevo proyecto creado dar click en la pesta�a de \"Proyecto\" en \"Consultar\".\n\n<<<<<<<<<<<<< | Para crear una tarea | >>>>>>>>>>>>>>>>>>>>\n\nDespu�s de haber creado un proyecto posicionarse en la pesta�a de \"Tarea\", posteriormente llenar campos de nombre de la tarea y dar click en \"Agregar\". Para ver la tarea creada dar click en la pesta�a de \"Tarea\" en \"Consultar\".\n\n<<<<<<<<<<<<< | Para problemas t�cnicos | >>>>>>>>>>>>>>>>>\n\nFavor de reportarse al correo AkLk700@gmail.com\no al n�mero telef�nico 833 704 2365");
        jScrollPane1.setViewportView(jtxacont);

        jButton2.setText("Generar");
        jButton2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton2ActionPerformed(evt);
            }
        });

        jButton3.setText("Direccion");
        jButton3.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton3ActionPerformed(evt);
            }
        });

        jtxtdir2.setEditable(false);

        jtxacont2.setEditable(false);
        jtxacont2.setColumns(20);
        jtxacont2.setRows(5);
        jtxacont2.setText("-----------------------------| MANUAL T�CNICO |-----------------------------\n                               \n<<<<<<<<<<<<<<<<<<<<<<< | �Qu� hace el sistema? | >>>>>>>>>>>>>>>>>>>>>>>>\n\nEl sistema gestor de desarrollo de proyectos de software \"A.K.L.K\" fue dise�ado para permitir la creaci�n de proyectos, los cuales pueden ser consultados permitiendo ver su nombre, el responsable de dicho proyecto, las tareas pendientes pertenecientes a dicho proyecto, los participantes asignados, as� como la fecha de inicio y de fin. Adem�s, permitir� agregar nuevos proyectos, asignando un nombre, objetivo, las fechas de inicio y fin, as� como una breve descripci�n del mismo y asignar a su responsable.\n\nPor otra parte, permitir� agregar tareas con sus respectivos nombres, fechas de inicio y de fin, el proyecto al que pertenece, breve descripciones, el estado (pendiente, en proceso, terminada, cancelada) y su prioridad (Baja, normal, urgente). Se permitir� su consulta.\n\nEn cuanto a los participantes, se les permitir� agregar m�s pidiendo su nombre, apellido paterno y materno, as� como su usuario y el cargo que ocupar� (participante, administrador del proyecto, administrador general). Se permitir� su consulta.\n\n\n<<<<<<<<<<<<<<<<<<<<<<< | Desarrollo | >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\nPara elaborar este sistema partimos del diagrama de E-R del sistema, as� como varios diagramas de clases y actividades que estuvimos realizando en clase. Conforme ibamos avanzando ibamos modificando detalles del proyecto y de los requisitos que no fueran primordiales, as� como tambi�n fuimos variando el dise�o de las interfaces conforme pasabamos a la programaci�n, ya que al momento de hacerla iban surgiendo m�s clases o ventanas que �bamos a ocupar para realizar ciertas acciones y que as� el programa fuera m�s funcional.\n\nMientras una persona del equipo se encargaba de ir avanzando con la programaci�n las otras iban realizando las actividades y las interfaces, as� el dise�o del logo.\nEn horas libres ve�amos en conjunto el programa y proporcionabamos ideas entre todos para ver c�mo ir�a quedando. Adem�s de ir corrigiendo la base de datos e ir haciendo pruebas para ver qu� cambiabamos.\n\nEn el programa existe una clase Conexion y CRUD dentro del paquete codigos, la primera sirviendo para la conexi�n a la base de datos de MySQL Workbench, y la segunda para los create, read, update, y delete.");
        jScrollPane2.setViewportView(jtxacont2);

        jButton4.setText("Generar");
        jButton4.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton4ActionPerformed(evt);
            }
        });

        jButton5.setText("Generar");
        jButton5.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton5ActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel1Layout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel1)
                .addGap(320, 320, 320))
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel1Layout.createSequentialGroup()
                .addGap(36, 36, 36)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(jScrollPane2)
                    .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 548, Short.MAX_VALUE)
                    .addComponent(jtxtdir)
                    .addComponent(jtxtdir2, javax.swing.GroupLayout.Alignment.LEADING))
                .addGap(18, 18, 18)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(jButton3)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(jButton1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(jButton2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                    .addComponent(jButton4))
                .addGap(55, 55, 55))
            .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel1Layout.createSequentialGroup()
                    .addContainerGap(620, Short.MAX_VALUE)
                    .addComponent(jButton5)
                    .addGap(45, 45, 45)))
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGap(18, 18, 18)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addComponent(jLabel1)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(jButton1)
                            .addComponent(jtxtdir, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                        .addGap(18, 18, 18)
                        .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 243, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(jButton2))
                .addGap(39, 39, 39)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jButton3)
                    .addComponent(jtxtdir2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(18, 18, 18)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 255, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jButton4))
                .addContainerGap(49, Short.MAX_VALUE))
            .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel1Layout.createSequentialGroup()
                    .addContainerGap(653, Short.MAX_VALUE)
                    .addComponent(jButton5)
                    .addGap(39, 39, 39)))
        );

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel1, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void jButton1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton1ActionPerformed
        // Bot�n direcci�n
        JFileChooser dlg = new JFileChooser();
        int option = dlg.showSaveDialog(this); //dialogo que guarda el archivo

        if (option == JFileChooser.APPROVE_OPTION) {
            File f = dlg.getSelectedFile();
            String f1 = f.toString();
            jtxtdir.setText(f1);
        }
    }//GEN-LAST:event_jButton1ActionPerformed

    private void jButton2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton2ActionPerformed
        // Bot�n generar
        String d = jtxtdir.getText();
        String tex = jtxacont.getText();
        try {
            FileOutputStream archivo = new FileOutputStream(d + ".pdf"); //para que se guarde como pdf
            Document doc = new Document();
            PdfWriter.getInstance(doc, archivo);
            doc.open();
            doc.add(new Paragraph(tex));
            doc.close();
            JOptionPane.showMessageDialog(null, "Documento creado");

        } catch (Exception e) {
            JOptionPane.showMessageDialog(null, "Error" + e);
        }
    }//GEN-LAST:event_jButton2ActionPerformed

    private void jButton3ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton3ActionPerformed
        // Bot�n direcci�n 2
        
        JFileChooser dlg2 = new JFileChooser();
        int option2 = dlg2.showSaveDialog(this); //dialogo que guarda el archivo

        if (option2 == JFileChooser.APPROVE_OPTION) {
            File f2 = dlg2.getSelectedFile();
            String f3 = f2.toString();
            jtxtdir2.setText(f3);
        }
    }//GEN-LAST:event_jButton3ActionPerformed

    private void jButton4ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton4ActionPerformed
        // Bot�n generar 2
        
        String d2 = jtxtdir2.getText();
        String tex2 = jtxacont2.getText();
        try {
            FileOutputStream archivo2 = new FileOutputStream(d2 + ".pdf"); //para que se guarde como pdf
            Document doc2 = new Document();
            PdfWriter.getInstance(doc2, archivo2);
            doc2.open();
            doc2.add(new Paragraph(tex2));
            doc2.close();
            JOptionPane.showMessageDialog(null, "Documento creado");

        } catch (Exception e) {
            JOptionPane.showMessageDialog(null, "Error" + e);
        }
    }//GEN-LAST:event_jButton4ActionPerformed

    private void jButton5ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton5ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jButton5ActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton jButton1;
    private javax.swing.JButton jButton2;
    private javax.swing.JButton jButton3;
    private javax.swing.JButton jButton4;
    private javax.swing.JButton jButton5;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JTextArea jtxacont;
    private javax.swing.JTextArea jtxacont2;
    private javax.swing.JTextField jtxtdir;
    private javax.swing.JTextField jtxtdir2;
    // End of variables declaration//GEN-END:variables
}
