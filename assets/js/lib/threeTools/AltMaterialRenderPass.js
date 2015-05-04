
// Renders the scene taking the alternative materials defined in the objects.
// "altMaterialPropertyName" is the name of the property which holds the alternative material in the objects
THREE.AltMaterialRenderPass = function ( altMaterialPropertyName, scene, camera, overrideMaterial, clearColor, clearAlpha ) {
    THREE.RenderPass.call(this, scene, camera, overrideMaterial, clearColor, clearAlpha);
    this.altMaterialPropName = altMaterialPropertyName;
    this.defaultMaterial = new THREE.MeshBasicMaterial({
        color: 0x000000
    });
};

THREE.AltMaterialRenderPass.prototype = {

    render: function ( renderer, writeBuffer, readBuffer, delta ) {
        this.prepareAltMaterialScene(this.scene.children);
        THREE.RenderPass.prototype.render.apply(this, arguments);
        this.restoreScene(this.scene.children)
    },

    prepareAltMaterialScene: function(objects) {
        if (objects === null || objects === undefined) {
            return;
        }

        for(var i = 0; i < objects.length; ++i) {
            var child = objects[i];

            var m = child[this.altMaterialPropName];
            if (m == undefined) {
                m = this.defaultMaterial;
            }

            child._originalMaterial = child.material;
            child.material = m;

            this.prepareAltMaterialScene(child.children)
        }
    },

    restoreScene: function(objects) {
        if (objects === null || objects === undefined) {
            return;
        }

        for(var i = 0; i < objects.length; ++i) {
            var child = objects[i];
            if (child._originalMaterial !== undefined) {
                child.material = child._originalMaterial
            }
            this.restoreScene(child.children)
        }
    }
};