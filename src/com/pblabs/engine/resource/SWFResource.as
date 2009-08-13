/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.resource 
{
    import flash.display.*;
    import flash.geom.*;
    import flash.system.ApplicationDomain;

    [EditorData(extensions="swf")]

    /**
     * This is a Resource subclass for SWF files. It makes it simpler
     * to load the files, and to get assets out from inside them.
     */
    public class SWFResource extends Resource
    {
        public function get clip():MovieClip 
        {
            return _clip;
        }

        public function get appDomain():ApplicationDomain 
        {
            return _appDomain; 
        }

        /**
         * Gets a new instance of the specified exported class contained in the SWF.
         * Returns a null reference if the exported name is not found in the loaded ApplicationDomain.
         *
         * @param name The fully qualified name of the exported class.
         */
        public function getExportedAsset(name:String):Object 
        {
            if (null == _appDomain) 
                throw new Error("not initialized");

            var assetClass:Class = getAssetClass(name);
            if (assetClass != null)
                return new assetClass();
            else
                return null;
        }

        /**
         * Gets a Class instance for the specified exported class name in the SWF.
         * Returns a null reference if the exported name is not found in the loaded ApplicationDomain.
         *
         * @param name The fully qualified name of the exported class.
         */
        public function getAssetClass(name:String):Class 
        {          
            if (null == _appDomain) 
                throw new Error("not initialized");

            if (_appDomain.hasDefinition(name))
                return _appDomain.getDefinition(name) as Class;
            else
                return null;
        }

        /**
         * Recursively searches all child clips for the maximum frame count.
         */
        public function findMaxFrames(parent:MovieClip, currentMax:int):int
        {
            for (var i:int=0; i < parent.numChildren; i++)
            {
                var mc:MovieClip = parent.getChildAt(i) as MovieClip;
                if(!mc)
                    continue;

                currentMax = Math.max(currentMax, mc.totalFrames);            

                findMaxFrames(mc, currentMax);
            }

            return currentMax;
        }


        /**
         * Recursively advances all child clips to the specified frame.
         * If the child does not have a frame at the position, it is skipped.
         */
        public function advanceChildClips(parent:MovieClip, frame:int):void
        {
            for (var j:int=0; j<parent.numChildren; j++)
            {
                var mc:MovieClip = parent.getChildAt(j) as MovieClip;
                if(!mc)
                    continue;

                if (mc.totalFrames >= frame)
                    mc.gotoAndStop(frame);

                advanceChildClips(mc, frame);
            }
        }

        /**
         * @inheritDoc
         */
        override protected function onContentReady(content:*):Boolean 
        {
            _clip = content as MovieClip;

            if (super.resourceLoader.contentLoaderInfo)
                _appDomain = super.resourceLoader.contentLoaderInfo.applicationDomain;

            return _clip != null;
        }

        private var _clip:MovieClip;
        private var _appDomain:ApplicationDomain;
    }
}
