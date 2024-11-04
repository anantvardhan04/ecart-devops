resource "aws_appmesh_virtual_service" "service" {

    name      = format("%s.%s.mesh", var.service_name, var.cluster_name)
    mesh_name = aws_appmesh_mesh.mesh.name

    spec {
        provider {
            virtual_node {
                virtual_node_name = aws_appmesh_virtual_node.blue.name
            }
         }
     }
 }