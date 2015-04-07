THREE.OcclusionRenderPass = function ( scene, camera, overrideMaterial, clearColor, clearAlpha ) {
    THREE.RenderPass.apply(this, arguments);
};

THREE.OcclusionRenderPass.prototype = {

    render: function ( renderer, writeBuffer, readBuffer, delta ) {
        this.overrideWithOcclusionMaterial(this.scene.children);
        THREE.RenderPass.prototype.render.apply(this, arguments);
        this.restoreOriginalMaterial(this.scene.children)
    },
    
    overrideWithOcclusionMaterial: function(objects) {
        if (objects === null || objects === undefined) {
            return;
        }

        for(var i = 0; i < objects.length; ++i) {
            var child = objects[i];
            if (child.occlusionMaterial !== undefined) {
                child.occlusionOriginalMaterial = child.material;
                child.material = child.occlusionMaterial
            }
            this.overrideWithOcclusionMaterial(child.children)
        }
    },
    
    restoreOriginalMaterial: function(objects) {
        if (objects === null || objects === undefined) {
            return;
        }

        for(var i = 0; i < objects.length; ++i)
        {
            var child = objects[i];
            if (child.occlusionOriginalMaterial !== undefined) {
                child.material = child.occlusionOriginalMaterial
            }
            this.restoreOriginalMaterial(child.children)
        }
    }

};