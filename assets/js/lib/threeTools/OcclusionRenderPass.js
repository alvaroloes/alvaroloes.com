THREE.OcclusionRenderPass = function ( scene, camera, overrideMaterial, clearColor, clearAlpha ) {
    THREE.RenderPass.apply(this, arguments);
    this.blackMaterial = new THREE.MeshBasicMaterial({
        color: 0x000000
    });
};

THREE.OcclusionRenderPass.prototype = {

    render: function ( renderer, writeBuffer, readBuffer, delta ) {
        this.prepareOcclusionScene(this.scene.children);
        THREE.RenderPass.prototype.render.apply(this, arguments);
        this.restoreScene(this.scene.children)
    },

    prepareOcclusionScene: function(objects) {
        if (objects === null || objects === undefined) {
            return;
        }

        for(var i = 0; i < objects.length; ++i) {
            var child = objects[i];

            var m = child.occlusionMaterial;
            if (m == undefined) {
                m = this.blackMaterial;
            }

            child._originalMaterial = child.material;
            child.material = m;

            this.prepareOcclusionScene(child.children)
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